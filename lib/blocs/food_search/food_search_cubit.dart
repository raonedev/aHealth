import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:ahealth/models/FoodSearchModel.dart';
import 'package:ahealth/secrets/secrets.dart';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
part 'food_search_state.dart';

class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit() : super(FoodSearchInitailize());

  Future<void> searchFood(String query) async {
    if(query.isEmpty){
      emit(const FoodSearchFailed(errorMessage: "Please enter food"));
      return;
    }
    emit(FoodSearchLoading());
    // OAuth parameters
    const String method = 'GET';
    const String url = 'https://platform.fatsecret.com/rest/server.api';
    final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final String nonce = Random().nextInt(1 << 32).toString();

    final Map<String, String> oauthParams = {
      'oauth_consumer_key': fatSecretConsumerKey,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_nonce': nonce,
      'oauth_version': '1.0',
      'method': 'foods.search',
      'search_expression': query,
      'format': 'json',
      'max_results': '10',
    };

    // Create Signature Base String
    final sortedParams = oauthParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final paramString = sortedParams.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    final signatureBaseString = '$method&${Uri.encodeComponent(url)}&${Uri.encodeComponent(paramString)}';

    // Sign the Base String
    final signingKey = '${Uri.encodeComponent(fatSecretConsumerSecret)}&';
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmac.convert(utf8.encode(signatureBaseString));
    final signature = base64Encode(digest.bytes);

    // Add signature to parameters
    oauthParams['oauth_signature'] = signature;

    // Send GET request
    final uri = Uri.parse('$url?${oauthParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      dev.log('Response: ${response.body}');
      emit(FoodSearchSuccess(foodSearchModel: FoodSearchModel.fromJson(jsonDecode(response.body))));
    } else {
      emit(FoodSearchFailed(errorMessage: 'Error: ${response.statusCode} ${response.body}'));
      dev.log('Error:', error: '${response.statusCode} ${response.body}');
    }
  }
}