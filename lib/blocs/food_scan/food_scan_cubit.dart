import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

import '../../models/nutrition_model.dart';
import '../../secrets/secrets.dart';

part 'food_scan_state.dart';

class FoodScanCubit extends Cubit<FoodScanState> {
  FoodScanCubit() : super(FoodScanInitial());

  static const _apiKey = GEMINI_API_KEY;
  // static const _model = 'gemma-4-26b-a4b-it';
  // static const _streamUrl =
  //     'https://generativelanguage.googleapis.com/v1beta/models/$_model:streamGenerateContent?alt=sse&key=$_apiKey';
  static const _fallbackModels = [
  'gemini-3.1-flash-lite',
  'gemini-2.5-flash-lite',
  'gemini-2.5-flash',
  'gemini-3-flash',
  'gemma-4-27b-it',
  'gemma-4-31b-it',
];
static String _urlFor(String model) =>
    'https://generativelanguage.googleapis.com/v1beta/models/$model:streamGenerateContent?alt=sse&key=$_apiKey';

  static const _csvHeaders =
      'name,calories,protein,fat,carbs,calcium,cholesterol,fiber,iron,potassium,sodium,sugar,quantity,unit,servingDescription,metricServingAmount,metricServingUnit,numberOfUnits,measurementDescription,saturatedFat,polyunsaturatedFat,monounsaturatedFat,vitaminA,vitaminC';

  static const _prompt = '''
Analyze this food image and identify ALL food items visible.
Return ONLY a CSV with this exact header row followed by one data row per item:
$_csvHeaders
eg: Apple,95,0.5,0.3,25.1,11.0,0.0,4.4,0.2,195.0,2.0,18.9,1.0,item,"1 medium (3"" dia)",182.0,g,1.0,medium,0.1,0.1,0.0,5.0,8.4

Rules:
- All numeric fields: numbers only, no units, empty string if unknown
- String fields: plain text, no commas inside values
- quantity: estimated quantity visible
- unit: piece/g/ml/slice etc
- servingDescription: e.g. "1 cup" or "1 medium"
- metricServingAmount: numeric string e.g. "240"
- metricServingUnit: g or ml
- numberOfUnits: numeric string
- measurementDescription: e.g. "cup" or "piece"
- NO markdown, NO explanation, NO extra text — only the CSV
''';

 Future<void> scanFoodImage({
  required String base64Image,
  required String groupUuid,
  required String imagePath,
}) async {
  emit(FoodScanLoading());

  try {
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            },
            {'text': _prompt},
          ]
        }
      ],
      'generationConfig': {'temperature': 0.2},
    });

    http.StreamedResponse? streamedResponse;

    for (final model in _fallbackModels) {
      final request = http.Request('POST', Uri.parse(_urlFor(model)))
        ..headers['Content-Type'] = 'application/json'
        ..body = body;

      try {
        final res = await request.send();
        if (res.statusCode == 200) {
          streamedResponse = res;
          break;
        } else if (res.statusCode == 429 || res.statusCode >= 500) {
          dev.log('Model $model returned ${res.statusCode}, trying next');
          continue;
        } else {
          final err = await res.stream.bytesToString();
          throw Exception('API error ${res.statusCode}: $err');
        }
      } catch (e) {
        dev.log('Model $model failed: $e');
        continue;
      }
    }

    if (streamedResponse == null) {
      throw Exception('All models failed or rate-limited');
    }

    String thinkingBuffer = '';
    String csvBuffer = '';

    await for (final line in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!line.startsWith('data: ')) continue;
      final jsonStr = line.substring(6).trim();
      if (jsonStr == '[DONE]' || jsonStr.isEmpty) continue;

      try {
        final chunk = jsonDecode(jsonStr);
        final parts = chunk['candidates']?[0]?['content']?['parts'] as List?;
        if (parts == null) continue;

        for (final part in parts) {
          final text = part['text'] as String? ?? '';
          if (part['thought'] == true) {
            thinkingBuffer += text;
            emit(FoodScanThinking(thinkingText: thinkingBuffer));
          } else {
            csvBuffer += text;
          }
        }
      } catch (e) {
        dev.log('SSE chunk parse error: $e');
      }
    }
    dev.log('CSV:\n$csvBuffer');

    final foods = _parseCsv(csvBuffer.trim());

    if (foods.isEmpty) {
      emit(FoodScanNoItems());
    } else {
      emit(FoodScanSuccess(
        foods: foods,
        thinkingText: thinkingBuffer.trim(),
        groupUuid: groupUuid,
        imagePath: imagePath,
      ));
    }
  } catch (e, s) {
    dev.log('FoodScanCubit error', error: e, stackTrace: s);
    emit(FoodScanError(message: e.toString()));
  }
}
  List<ValueFood> _parseCsv(String csv) {
    final lines = csv
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return [];

    final dataLines = lines.skip(1).toList();
    final foods = <ValueFood>[];
    final headers = _csvHeaders.split(',');

    for (final line in dataLines) {
      try {
        final values = _splitCsvLine(line);
        if (values.length < headers.length) continue;

        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length; i++) {
          final key = headers[i];
          final val = values[i].trim();
          const numericFields = {
            'calories',
            'protein',
            'fat',
            'carbs',
            'calcium',
            'cholesterol',
            'fiber',
            'iron',
            'potassium',
            'sodium',
            'sugar',
            'quantity',
            'saturatedFat',
            'polyunsaturatedFat',
            'monounsaturatedFat',
            'vitaminA',
            'vitaminC',
          };
          if (numericFields.contains(key)) {
            map[key] = val.isEmpty ? null : double.tryParse(val);
          } else {
            map[key] = val.isEmpty ? null : val;
          }
        }

        foods.add(ValueFood.fromJson(map));
      } catch (e) {
        dev.log('CSV parse error for line: $line', error: e);
      }
    }

    return foods;
  }

  List<String> _splitCsvLine(String line) => line.split(',');
}
