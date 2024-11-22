import 'dart:convert';

import '../../models/FoodWithServingsModel.dart';
import '../../secrets/secrets.dart';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

part 'food_detail_state.dart';

class FoodDetailCubit extends Cubit<FoodDetailState> {
  FoodDetailCubit() : super(FoodDetailInitial());

  void fetchFoodDetails(String foodId) async {
    if(foodId.isEmpty){
      emit(const FoodDetailFailed(errorMessage: "foodId not found"));
      return;
    }
    emit(FoodDetailLoading());
    const String url = "https://platform.fatsecret.com/rest/server.api";

    // Step 1: OAuth Parameters
    final oauthParams = {
      'oauth_consumer_key': fatSecretConsumerKey,
      'oauth_nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'oauth_version': '1.0',
      'method': 'food.get.v4',
      'food_id': foodId,
      'format': 'json',
    };

    // Step 2: Sort parameters and construct the signature base string
    final sortedParams = oauthParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final baseString = sortedParams.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    final signatureBaseString = 'GET&${Uri.encodeComponent(url)}&${Uri.encodeComponent(baseString)}';

    // Step 3: Generate the HMAC-SHA1 signature
    final signingKey = '${Uri.encodeComponent(fatSecretConsumerSecret)}&'; // No token secret for 2-legged OAuth
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
        // final List<dynamic>  servingData = data['food']['servings']['serving'];
        // // Example: Accessing individual servings
        // for (var serving in servingData) {
        //   dev.log('Serving Description: ${serving['serving_description']}, Calories: ${serving['calories']}');
        // }

        dev.log(response.body.toString());
        
        emit(FoodDetailSuccess(foodWithServingsModel: FoodWithServingsModel.fromJson(data)));


      } else {
        dev.log('Error: ${response.statusCode} - ${response.body}');
        emit(FoodDetailFailed(errorMessage: 'Error: ${response.statusCode} - ${response.body}'));
      }
    } catch (e) {
      dev.log('Exception: $e');
      emit(FoodDetailFailed(errorMessage: 'Exception: $e'));
    }
  }
}
