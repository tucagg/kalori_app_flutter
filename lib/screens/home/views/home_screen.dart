import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../image_service.dart';
import '../dialog_helper.dart';
import 'package:flutter_svg/flutter_svg.dart'; // flutter_svg paketini içeri aktarıyoruz
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences paketini içeri aktarıyoruz
import 'package:kalori/api_key.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _isLoading = false;
  final ImageService _imageService = ImageService(ApiKeys.openAI,);

  // Pick and process image
  Future<void> _pickAndProcessImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ImageService ile fotoğrafı işle ve sonucu al
      final calories = await _imageService.handleProcessImage(source);

      // Sonuçları dialog ile göster
      DialogHelper.showResponseDialog(
        context,
        calories,
      );
    } catch (e) {
      DialogHelper.showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Seçenekleri gösteren dialog fonksiyonu
  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pick from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndProcessImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Capture Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndProcessImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's calculate calories!"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
              )
            else
              GestureDetector(
                onTap: _showOptionsDialog,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/empty_plate.svg', // Boş tabak SVG dosyasının yolu
                      height: 150, // Tabak boyutunu artırdık
                    ),
                    const SizedBox(height: 20), // Arayı büyütüyoruz
                    const Text(
                      "Tap the plate to add a food",
                      style: TextStyle(
                        fontSize: 18, // Yazı boyutunu artırdık
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
