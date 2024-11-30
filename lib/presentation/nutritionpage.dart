import 'dart:convert'; // Used for JSON encoding and decoding
import 'dart:developer'; // For logging errors and debugging
import 'dart:io'; // For working with files (image files in this case)
// import 'dart:typed_data'; // For handling byte data (image in bytes)

import 'package:flutter/cupertino.dart';

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
      body: Column(
        children: [
          // Display the picked image, if any
          res != null ? Image.file(File(res!.path)) : const SizedBox(),

          // Show the response text from AI (nutritional info)
          Text(responseText),
          

          if(isLoading) const CupertinoActivityIndicator(),
          if(foodItemList.isNotEmpty) Expanded(child: ListView.builder(
            itemCount: foodItemList.length,
            itemBuilder: (context, index) {
              final foodItem = foodItemList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.green,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text("name:${foodItem.name}\nQuantity:${foodItem.quantity} ${foodItem.unit}\ncalories:${foodItem.calories}\nsugar:${foodItem.sugar}\nfiber:${foodItem.fiber}\npotassium:${foodItem.potassium}\ncarbs:${foodItem.carbs}"),
                  ),
                ),
              );
            },
          )),

          // Button to trigger AI response generation
          ElevatedButton(
            onPressed: () async {
              if (res != null) {
                setState(() {
                  isLoading= true;
                });
                await getResponseFromAI(image: res!); // Call AI if image is picked
              } else {
                // Show error message if no image is selected
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select an image")));
              }
              setState(() {
                isLoading =false;
              });
            },
            child: const Text("Generate"), // Button label
          ),
        ],
      ),

      // Floating Action Buttons for picking image from gallery or camera
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Floating action button for selecting image from gallery
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: 'gallery',
              onPressed: () async {
                final image =
                await _picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  res = image; // Update the image file state
                });
              },
              child: const Icon(Icons.image_outlined), // Icon for gallery
            ),
          ),
          // Floating action button for taking picture with camera
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: "camera",
              onPressed: () async {
                final image =
                await _picker.pickImage(source: ImageSource.camera);
                setState(() {
                  res = image; // Update the image file state
                });
              },
              child: const Icon(Icons.camera), // Icon for camera
            ),
          ),
        ],
      ),
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
            foodItemList = jsonList.map((json) => ValueFood.fromJson(json)).toList();
          });
        }

      }
    } catch (e) {
      // Log any errors encountered
      log("An Error Occurred:", error: e);
    }
  }
}
