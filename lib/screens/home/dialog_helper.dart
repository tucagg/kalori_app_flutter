import 'dart:convert';
import 'package:flutter/material.dart';

class DialogHelper {
  // Show response dialog
  static void showResponseDialog(BuildContext context, String response) {
    try {
      // Clean up and parse JSON
      String cleanedResponse = response.trim();
      int startIndex = cleanedResponse.indexOf('{');
      int endIndex = cleanedResponse.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1) {
        throw Exception("Invalid JSON format");
      }
      cleanedResponse = cleanedResponse.substring(startIndex, endIndex + 1);

      final jsonResponse = jsonDecode(cleanedResponse);

      String foodName = jsonResponse['food_name'] ?? "Unknown";
      String grams = jsonResponse['grams']?.toString() ?? "Unknown";
      String calorie = jsonResponse['calorie']?.toString() ?? "Unknown";

      // Show dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Food Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Name: $foodName"),
              Text("Grams: $grams"),
              Text("Calories: $calorie"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error dialog in case of invalid response
      showErrorDialog(context, "Failed to parse response: $e");
    }
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}