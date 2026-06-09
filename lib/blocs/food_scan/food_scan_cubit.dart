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
  static const _model = 'gemma-4-26b-a4b-it';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

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

  Future<void> scanFoodImage(String base64Image) async {
    emit(FoodScanLoading());

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;
      if (parts == null) throw Exception('No parts in response');

      String csvText = '';
      String thinkingText = '';

      for (final part in parts) {
        final text = part['text'] as String? ?? '';
        if (part['thought'] == true) {
          thinkingText += text;
        } else {
          csvText += text;
        }
      }

      dev.log('Thinking:\n$thinkingText');
      dev.log('CSV:\n$csvText');

      final foods = _parseCsv(csvText.trim());

      if (foods.isEmpty) {
        emit(FoodScanNoItems());
      } else {
        emit(FoodScanSuccess(foods: foods, thinkingText: thinkingText.trim()));
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

    // Skip header row
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
          // Numeric fields
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

  List<String> _splitCsvLine(String line) {
    // Simple CSV split (no quoted commas support needed per prompt rules)
    return line.split(',');
  }
}
