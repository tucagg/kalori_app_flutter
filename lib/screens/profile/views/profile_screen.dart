import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'model_handler.dart';

class SharedPrefHelper {
  static const String _outputMessageKey = 'profile_output_message';

  static Future<void> saveOutputMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outputMessageKey, message);
  }

  static Future<String?> getOutputMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_outputMessageKey);
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String _outputMessage = "Henüz bir fotoğraf yüklemediniz.";
  final ImagePicker _picker = ImagePicker();
  late ModelHandler _modelHandler;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _initializeModelHandler();
  }

  Future<void> _initializeModelHandler() async {
    _modelHandler = ModelHandler();
    await _modelHandler.loadModels(
      'assets/ai_model/model_gender_q.tflite',
      'assets/ai_model/model_age_q.tflite',
    );
  }

  // Kalori hesaplama fonksiyonu
  int calculateCalories(String gender, int age) {
    if (gender.toLowerCase() == 'male') {
      if (age >= 19 && age <= 30) {
        return 2500;
      } else if (age <= 50) {
        return 2300;
      } else {
        return 2100;
      }
    } else if (gender.toLowerCase() == 'female') {
      if (age >= 19 && age <= 30) {
        return 2200;
      } else if (age <= 50) {
        return 1900;
      } else {
        return 1700;
      }
    } else {
      // Bilinmeyen cinsiyet durumunda varsayılan değer
      return 2000;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        // Benzersiz bir dosya adı oluşturun, örneğin zaman damgası ile
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedImagePath = '${appDir.path}/profile_$timestamp.jpg';

        // Yeni fotoğrafı kaydet
        final savedImage = await File(pickedFile.path).copy(savedImagePath);

        // UI'de hemen fotoğrafı güncelle
        setState(() {
          _profileImage = savedImage;
          _outputMessage = "Model çalıştırılıyor...";
        });

        // Modeli çalıştır
        _modelHandler.runGenderModelOnImage(savedImage).then((genderResult) {
          _modelHandler.runAgeModelOnImage(savedImage).then((ageResult) {
            // Yaş sonucunu integer'a çevir
            int age = int.tryParse(ageResult) ?? 25; // Hata durumunda varsayılan yaş 25
            // Kalori hesapla
            int calories = calculateCalories(genderResult, age);
            String calorieMessage = "The amount of calories you should consume during the day: $calories";

            final result = "$genderResult, $ageResult\n$calorieMessage";

            // Sonuçları kaydet ve UI'yi güncelle
            SharedPrefHelper.saveOutputMessage(result).then((_) {
              setState(() {
                _outputMessage = result;
              });
            });
          });
        });

        // Önceki fotoğrafları temizlemek isterseniz (opsiyonel)
        _cleanupOldImages(appDir.path, savedImagePath);
      } catch (e) {
        setState(() {
          _outputMessage = "Bir hata oluştu: $e";
        });
      }
    } else {
      setState(() {
        _outputMessage = "Hiçbir fotoğraf seçilmedi.";
      });
    }
  }

  // Eski fotoğrafları silmek için opsiyonel bir fonksiyon
  Future<void> _cleanupOldImages(String directoryPath, String currentImagePath) async {
    final directory = Directory(directoryPath);
    final files = directory.listSync();
    for (var file in files) {
      if (file is File && file.path != currentImagePath && file.path.startsWith('${directory.path}/profile_')) {
        await file.delete();
      }
    }
  }

  Future<void> _loadProfileImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory(appDir.path);
    final files = directory.listSync();

    File? latestImage;
    String? outputMessage;

    for (var file in files) {
      if (file is File && file.path.startsWith('${directory.path}/profile_') && file.path.endsWith('.jpg')) {
        if (latestImage == null || file.lastModifiedSync().isAfter(latestImage.lastModifiedSync())) {
          latestImage = file;
        }
      }
    }

    outputMessage = await SharedPrefHelper.getOutputMessage();

    if (latestImage != null) {
      setState(() {
        _profileImage = latestImage;
        _outputMessage = outputMessage ?? "Sonuç bulunamadı.";
      });
    } else {
      setState(() {
        _outputMessage = "Henüz bir fotoğraf yüklemediniz.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/icons/default_profile.jpg') as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  _outputMessage,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}