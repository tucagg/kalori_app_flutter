import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalori/api_key.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  // List to hold the menu data
  List<Map<String, String>> dailyMenu = [];

  // OpenAI API URL and key
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  final String apiKey = ApiKeys.openAI; // Replace with your API key

  // Fetch recipes from SharedPreferences
  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Function to load recipes from SharedPreferences
  Future<void> _loadRecipes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? recipesString = prefs.getString('recipe');
    if (recipesString != null) {
      List<dynamic> recipesList = jsonDecode(recipesString);
      setState(() {
        dailyMenu = List<Map<String, String>>.from(
            recipesList.map((item) => Map<String, String>.from(item)));
      });
    }
  }

  // Function to save recipes to SharedPreferences
  Future<void> _saveRecipes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String recipesString = jsonEncode(dailyMenu);
    await prefs.setString('recipe', recipesString);
  }

  // Function to make the API call
  Future<Map<String, String>?> _fetchRecipe(String mealType) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a healthy recipe generator. Provide a valid JSON response containing 'food_name', 'calories', and a short summarized 'recipe'. Do not use triple quotes or markdown formatting."
            },
            {
              "role": "user",
              "content": "Give me a $mealType recipe."
            },
          ],
          "temperature": 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data["choices"][0]["message"]["content"];

        // Clean and sanitize the content
        content = content.trim(); // Remove leading/trailing whitespace
        if (content.startsWith("```json") || content.startsWith("```")) {
          // Remove markdown-like code block formatting
          content = content.replaceAll(RegExp(r'^```(json)?|```$'), '').trim();
        }
        content = content.replaceAll("'''", "").trim(); // Remove triple quotes if any

        // Attempt to parse the cleaned JSON
        final jsonContent = jsonDecode(content);
        print("CLEANED JSON: $jsonContent");

        return {
          "food_name": jsonContent["food_name"] ?? "Unknown",
          "calories": jsonContent["calories"]?.toString() ?? "N/A",
          "recipe": jsonContent["recipe"] ?? "No recipe available.",
        };
      } else {
        print("Error: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching recipe: $e");
    }
    return null;
  }

  // Show dialog to ask meal type and fetch recipe
  void _showMealTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Choose Meal Type"),
          children: [
            SimpleDialogOption(
              child: const Text("Breakfast"),
              onPressed: () => _handleRecipeFetch("breakfast"),
            ),
            SimpleDialogOption(
              child: const Text("Lunch"),
              onPressed: () => _handleRecipeFetch("lunch"),
            ),
            SimpleDialogOption(
              child: const Text("Dinner"),
              onPressed: () => _handleRecipeFetch("dinner"),
            ),
            SimpleDialogOption(
              child: const Text("Quick Snack"),
              onPressed: () => _handleRecipeFetch("quick snack"),
            ),
          ],
        );
      },
    );
  }

  // Fetch recipe and add it to the menu
  void _handleRecipeFetch(String mealType) async {
    Navigator.pop(context); // Close the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final recipeData = await _fetchRecipe(mealType);

    Navigator.pop(context); // Close the loading indicator
    if (recipeData != null) {
      setState(() {
        dailyMenu.add(recipeData);
        _saveRecipes(); // Save the updated menu to SharedPreferences
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch recipe. Try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu of the Day"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showMealTypeDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dailyMenu.length,
        itemBuilder: (context, index) {
          final item = dailyMenu[index];
          return ExpansionTile(
            leading: const Icon(Icons.fastfood),
            title: Text(item["food_name"]!),
            subtitle: Text(item["calories"]!),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["recipe"]!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          dailyMenu.removeAt(index);
                          _saveRecipes(); // Save after deleting an item
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}