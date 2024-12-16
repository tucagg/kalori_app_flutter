import 'package:flutter/material.dart';

import '../../home/image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // SharedPreferences'den veriyi yükleme fonksiyonu
  Future<void> _loadHistory() async {
    final imageService = ImageService("your-api-key"); // API key'i girin
    final loadedHistory = await imageService.loadHistory();

    setState(() {
      history = loadedHistory;
    });
  }

  // SharedPreferences'teki veriyi temizleme fonksiyonu
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history'); // Geçmişi temizler

    // Verilerin temizlendiğini bildiren bir mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History cleared')),
    );

    // Temizleme işleminden sonra ekrandaki veriyi de sıfırlayın
    setState(() {
      history = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          // Clear History butonu
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory, // Geçmişi temizle
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text("No history available"))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            title: Text(item['food_name']!),
            subtitle: Text(
              "${item['grams']} grams, ${item['calories']} kcal",
            ),
          );
        },
      ),
    );
  }
}