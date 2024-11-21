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

/*


   void fetchFoodDetails(String foodId) async {
    const String url = "https://platform.fatsecret.com/rest/server.api";
    const String consumerKey = '55c01805a86c44a88543eadfabcd3e3a'; // Replace with your Consumer Key
    const String consumerSecret = '423c6978fd7e43e4a4f560b0fb687e38'; // Replace with your Consumer Secret

    // Step 1: OAuth Parameters
    final oauthParams = {
      'oauth_consumer_key': consumerKey,
      'oauth_nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'oauth_version': '1.0',
      'method': 'food.get.v4',
      'food_id': foodId,
      'format': 'json',
    };

    // Step 2: Sort parameters and construct the signature base string
    final sortedParams = oauthParams.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final baseString = sortedParams.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    final signatureBaseString = 'GET&${Uri.encodeComponent(url)}&${Uri.encodeComponent(baseString)}';

    // Step 3: Generate the HMAC-SHA1 signature
    final signingKey = '${Uri.encodeComponent(consumerSecret)}&'; // No token secret for 2-legged OAuth
    final hmacSha1 = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmacSha1.convert(utf8.encode(signatureBaseString));
    final oauthSignature = base64Encode(digest.bytes);

    // Step 4: Add the signature to parameters
    oauthParams['oauth_signature'] = oauthSignature;

    // Step 5: Construct the final request URI
    final queryString = oauthParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    final requestUri = Uri.parse('$url?$queryString');

    // Step 6: Send the request
    try {
      final response = await http.get(requestUri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic>  servingData = data['food']['servings']['serving'];
        // Example: Accessing individual servings
        for (var serving in servingData) {
          dev.log('Serving Description: ${serving['serving_description']}, Calories: ${serving['calories']}');
        }

      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

 */