import 'dart:convert'; // Used for JSON encoding and decoding
import 'dart:developer'; // For logging errors and debugging
import 'dart:io'; // For working with files (image files in this case)
import 'dart:ui';
// import 'dart:typed_data'; // For handling byte data (image in bytes)

import 'package:ahealth/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/nutrition/nutrition_cubit.dart';
import '../models/NutritionModel.dart';
import 'package:flutter/material.dart'; // UI components for the app
import 'package:google_generative_ai/google_generative_ai.dart'; // Google's generative AI package
import 'package:image_picker/image_picker.dart';

import '../secrets/secrets.dart';

/// HomeScreen is the main widget for displaying the interface.
/// It allows the user to pick an image, send it to the generative AI, and display food information.
class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  // Image picker for selecting images from gallery or camera
  final ImagePicker _picker = ImagePicker();

  // Holds the picked image as a file (from camera or gallery)
  XFile? res;

  // Stores the response text from the AI model
  String responseText = "";

  // Instance of the GenerativeModel for calling AI services
  late final GenerativeModel _model;

  // Flag to indicate if loading (useful for showing loading spinners)
  bool isLoading = false;

  // The prompt that instructs the AI on what to return (JSON nutritional data)
  final String prompt = """
  
You are an AI that provides nutritional information about food items. Your response must strictly adhere to this JSON structure:

[
  {
    "name": "String",
    "calories": "double",
    "protein": "double",
    "fat": "double",
    "carbs": "double",
    "calcium": "double",
    "cholesterol": "double",
    "fiber": "double",
    "iron": "double",
    "potassium": "double",
    "sodium": "double",
    "sugar": "double",
    "quantity": "double",
    "unit": "String",
    "servingDescription": "String",
    "metricServingAmount": "String",
    "metricServingUnit": "String",
    "numberOfUnits": "String",
    "measurementDescription": "String",
    "saturatedFat": "double",
    "polyunsaturatedFat": "double",
    "monounsaturatedFat": "double",
    "vitaminA": "double",
    "vitaminC": "double"
  }
]

Respond with only the JSON String with no Markdown formatting like ( ```json), no explanations, no extra characters. The response should start and end with the JSON brackets ([ and ]) only.
  
  """;

  // List to store the parsed food items from the AI's JSON response
  List<ValueFood> foodItemList = [];

  /// Initializes the generative model with the API key and model identifier
  @override
  void initState() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Specify the AI model
      apiKey: GEMINI_API_KEY, // API Key for authentication
    );
    super.initState();
  }

  /// Builds the UI layout of the home screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display the picked image, if any
                res != null ? Image.file(File(res!.path)) : const SizedBox(),
                // Button to trigger AI response generation
                res != null
                    ? ElevatedButton(
                        onPressed: () async {
                          if (res != null) {
                            setState(() {
                              isLoading = true;
                            });
                            await getResponseFromAI(image: res!); // Call AI if image is picked
                          } else {
                            // Show error message if no image is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select an image")));
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Text(
                          "Generate",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: white),
                        ), // Button label
                      )
                    : const Text("Take Picture of your meal"),
                if (isLoading) const CupertinoActivityIndicator(),
                if (foodItemList.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: foodItemList.length,
                      itemBuilder: (context, index) {
                        final foodItem = foodItemList[index];
                        return Container(
                          //(index==foodItemList.length-1)?200:0
                          margin:  EdgeInsets.only(left: 16,right: 16,top: 8,bottom: (index==foodItemList.length-1)?100:8,),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text("name:${foodItem.name}\nQuantity:${foodItem.quantity} ${foodItem.unit}\ncalories:${foodItem.calories}\nsugar:${foodItem.sugar}\nfiber:${foodItem.fiber}\npotassium:${foodItem.potassium}\ncarbs:${foodItem.carbs}"),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // bottom bar
          // Bottom bar with iOS-style blur
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              // Rounded corners like iOS
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                // Blur intensity
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Match clip radius
                    border: Border.all(
                      // Add this border property
                      color: white,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (foodItemList.isNotEmpty) ...[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CupertinoButton.filled(
                              padding: const EdgeInsets.all(12),
                              onPressed: () {
                                for (final foodItem in foodItemList) {
                                  context
                                      .read<NutritionCubit>()
                                      .addNutritionData(valueFood: foodItem);
                                }
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                              child: const Text("Log Meal"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      FloatingActionButton(
                        backgroundColor: primary,
                        heroTag: 'gallery',
                        onPressed: () async {
                          final image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() => res = image);
                        },
                        child: const Icon(
                          Icons.image_outlined,
                          color: white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        backgroundColor: primary,
                        heroTag: "camera",
                        onPressed: () async {
                          final image = await _picker.pickImage(
                              source: ImageSource.camera);
                          setState(() => res = image);
                        },
                        child: const Icon(
                          Icons.camera,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),

      // // Floating Action Buttons for picking image from gallery or camera
      // floatingActionButton: Row(
      //   children: [
      //     Expanded(
      //       child: (foodItemList.isNotEmpty)
      //           ? Padding(
      //               padding: const EdgeInsets.only(
      //                   left: 28, top: 8, bottom: 8, right: 4),
      //               child: CupertinoButton.filled(
      //                   onPressed: () {
      //                     for(final foodItem in foodItemList){
      //                       context.read<NutritionCubit>().addNutritionData(valueFood: foodItem);
      //                     }
      //                     Navigator.popUntil(context, (route) => route.isFirst);
      //                   }, child: const Text("Log Meal")),
      //             )
      //           : const SizedBox(),
      //     ),
      //     // Floating action button for selecting image from gallery
      //     FloatingActionButton(
      //       heroTag: 'gallery',
      //       onPressed: () async {
      //         final image =
      //             await _picker.pickImage(source: ImageSource.gallery);
      //         setState(() {
      //           res = image; // Update the image file state
      //         });
      //       },
      //       child: const Icon(Icons.image_outlined), // Icon for gallery
      //     ),
      //     // Floating action button for taking picture with camera
      //     FloatingActionButton(
      //       heroTag: "camera",
      //       onPressed: () async {
      //         final image = await _picker.pickImage(source: ImageSource.camera);
      //         setState(() {
      //           res = image; // Update the image file state
      //         });
      //       },
      //       child: const Icon(Icons.camera), // Icon for camera
      //     ),
      //   ],
      // ),
    );
  }

  /// Sends the selected image to the AI and receives the response.
  /// This function reads the image file, sends it to the AI model,
  /// and processes the response as JSON to update the UI with food data.
  Future<void> getResponseFromAI({required XFile image}) async {
    // Read the image file into a byte array
    final imageByte = await File(image.path).readAsBytes();

    // Prepare content for AI model: image and prompt
    final content = [
      Content.multi([DataPart('image/jpeg', imageByte), TextPart(prompt)]),
    ];

    try {
      // Send request to AI and get response
      final response = await _model.generateContent(content);

      // Log the AI's response for debugging
      log("response: ${response.text ?? "No response"}");

      if (response.text != null) {
        // Extract the JSON part using regex to remove non-JSON characters
        RegExp regex = RegExp(r'```json\n([\s\S]+?)\n```');
        Match? match = regex.firstMatch(response.text!);

        if (match != null) {
          String jsonString = match.group(1)!;

          //log extracted json
          log("jsonString: $jsonString");

          // Parse the response text as JSON and update the list of food items
          List<dynamic> jsonList = jsonDecode(jsonString);
          setState(() {
            foodItemList =
                jsonList.map((json) => ValueFood.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      // Log any errors encountered
      log("An Error Occurred:", error: e);
    }
  }
}
