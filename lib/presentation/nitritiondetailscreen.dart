import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/NutritionModel.dart';

class NutritionDetailScreen extends StatelessWidget {
  final NutritionModel nutritionModel;

  NutritionDetailScreen({required this.nutritionModel});

  @override
  Widget build(BuildContext context) {
    // Retrieve data from nutritionModel
    final valueFood = nutritionModel.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Information"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the food name
              Text(
                valueFood?.name ?? "Unknown",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18
                ),
              ),
              const SizedBox(height: 16.0),
          
              // Macronutrients section
              buildMacronutrients(valueFood),
              const SizedBox(height: 16.0),
          
              // Micronutrients section
              buildMicronutrients(valueFood),
              const SizedBox(height: 16.0),
          
              // Vitamins section
              buildVitamins(valueFood),
              const SizedBox(height: 16.0),
          
              // Serving size
              // buildServingSize(valueFood),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMacronutrients(ValueFood? valueFood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildNutrientCard('Calories', valueFood?.calories),
        buildNutrientCard('Protein', valueFood?.protein),
        buildNutrientCard('Fat', valueFood?.fat),
        buildNutrientCard('Carbs', valueFood?.carbs),
        buildNutrientCard('Fiber', valueFood?.fiber),
        buildNutrientCard('Sugar', valueFood?.sugar),
      ],
    );
  }

  Widget buildNutrientCard(String title, double? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        trailing: Text(value != null ? value.toString() : "N/A"),
      ),
    );
  }

  Widget buildMicronutrients(ValueFood? valueFood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildNutrientRow('Calcium', valueFood?.calcium),
        buildNutrientRow('Cholesterol', valueFood?.cholesterol),
        buildNutrientRow('Iron', valueFood?.iron),
        buildNutrientRow('Potassium', valueFood?.potassium),
        buildNutrientRow('Sodium', valueFood?.sodium),
      ],
    );
  }

  Widget buildNutrientRow(String title, double? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(value != null ? value.toString() : "N/A"),
      ],
    );
  }

  Widget buildVitamins(ValueFood? valueFood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildNutrientRow('Vitamin A', valueFood?.vitaminA),
        buildNutrientRow('Vitamin C', valueFood?.vitaminC),
      ],
    );
  }

  // Widget buildServingSize(ValueFood? valueFood) {
  //   log("servingDescription : "+valueFood!.servingDescription.toString());
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text("Serving Size"),
  //       Text(valueFood?.servingDescription ?? "N/A"),
  //     ],
  //   );
  // }
}
