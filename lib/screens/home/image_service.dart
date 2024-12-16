import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  final String apiKey;

  ImageService(this.apiKey);

  final ImagePicker _picker = ImagePicker();

  // Pick an image
  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }

  // Handle process image and send response
  Future<String> handleProcessImage(ImageSource source) async {
    try {
      // Pick image
      final image = await pickImage(source);
      if (image == null) {
        throw Exception("No image selected");
      }

      // Convert image to Base64
      final bytes = await File(image.path).readAsBytes();
      String base64Image = base64Encode(bytes);

      // OpenAI API endpoint
      const String apiUrl = "https://api.openai.com/v1/chat/completions";

      // Request payloadz
      final Map<String, dynamic> payload = {
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "Return json formatted answer for the following: Name of the food ( food_name ), estimated grams ( grams ), and estimated total calorie ( calorie ). Make sure your response is only a json"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image"
                }
              }
            ]
          }
        ],
        "max_tokens": 300
      };

      // Make API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Process response
        // PARSINGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
        final parsedResponse = customJsonDecode(response.body);
        String calories = parsedResponse['choices'][0]['message']['content'];

        // Save the history
        await _saveHistory(calories);

        return calories; // Return calories as response
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to process image: $e");
    }
  }

  // Save calories directly to shared preferences
  Future<void> _saveHistory(String calories) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(calories);  // Directly add calories without any prefix
    await prefs.setStringList('history', history);

    // Debugging
    print('Saved history: $history');
  }

  Future<List<Map<String, String>>> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyData = prefs.getStringList('history') ?? [];

    // Parse the history data and convert to List<Map<String, String>>
    return historyData.map((item) {
      final parsedData = customJsonDecode(item); // Parsing the JSON string

      // Dönüştürme işlemi: JSON verisini String'e çevir
      return {
        'food_name': parsedData['food_name']?.toString() ?? '', // food_name'i String'e çevir
        'grams': parsedData['grams']?.toString() ?? '0', // grams'ı String'e çevir
        'calories': parsedData['calorie']?.toString() ?? '0', // calorie'yi String'e çevir
      };
    }).toList();
  }


}



Map<String, dynamic> customJsonDecode(String responseBody) {
  // Step 1: Clean up the unwanted characters
  String cleanedResponse = responseBody.trim();

  // Remove everything before the actual JSON (starts with "json{" and ends with "}")
  cleanedResponse = cleanedResponse.replaceAll(RegExp(r'^[^j]*json'), ''); // Remove anything before 'json'
  cleanedResponse = cleanedResponse.replaceAll(RegExp(r'[^}]*$'), '');    // Remove anything after the closing '}'

  // Step 2: Now we have the valid JSON part, attempt to decode it
  try {
    return jsonDecode(cleanedResponse);
  } catch (e) {
    // Handle error if the response is still not valid JSON
    throw Exception("Failed to parse JSON: $e");
  }
}

