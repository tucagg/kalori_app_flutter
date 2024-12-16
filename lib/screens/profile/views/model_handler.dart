import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;


class ModelHandler {
  late Interpreter _genderInterpreter;
  late Interpreter _ageInterpreter;

  Future<void> loadModels(String genderModelPath, String ageModelPath) async {
    // Cinsiyet ve yaş modellerini yükle
    _genderInterpreter = await Interpreter.fromAsset(genderModelPath);
    _ageInterpreter = await Interpreter.fromAsset(ageModelPath);
  }

  Future<String> runGenderModelOnImage(File imageFile) async {
    // Resmi yükle ve uygun boyuta getir
    final inputImage = img.decodeImage(await imageFile.readAsBytes());
    if (inputImage == null) {
      return "Resim işlenemedi!";
    }

    // Cinsiyet modeli için giriş boyutuna göre yeniden boyutlandır
    final resizedImage = img.copyResize(inputImage, width: 128, height: 128);

    // Giriş tensorünü oluştur ve normalize et
    var input = _imageToByteList(resizedImage, 128, 128);

    // Çıkış tensorünü hazırla
    var output = List.filled(2, 0.0).reshape([1, 2]);

    // Modeli çalıştır
    try {
      _genderInterpreter.run(input, output);

      // Çıktıyı yorumla
      final probabilities = output[0];
      return _interpretGenderOutput(probabilities);
    } catch (e) {
      return "Cinsiyet modeli çalıştırılamadı: $e";
    }
  }

  Future<String> runAgeModelOnImage(File imageFile) async {
    // Resmi yükle ve uygun boyuta getir
    final inputImage = img.decodeImage(await imageFile.readAsBytes());
    if (inputImage == null) {
      return "Resim işlenemedi!";
    }

    // Yaş modeli için giriş boyutuna göre yeniden boyutlandır
    final resizedImage = img.copyResize(inputImage, width: 200, height: 200);

    // Giriş tensorünü oluştur ve normalize et
    var input = _imageToByteList(resizedImage, 200, 200);

    // Çıkış tensorünü hazırla
    var output = List.filled(1, 0.0).reshape([1, 1]);

    // Modeli çalıştır
    try {
      _ageInterpreter.run(input, output);

      // Çıktıyı yorumla ve ölçeklendirme uygula
      final rawAge = output[0][0];
      final scaledAge = rawAge * 100; // Örnek ölçeklendirme

      return "Age: ${scaledAge.toStringAsFixed(1)}";
    } catch (e) {
      return "Yaş modeli çalıştırılamadı: $e";
    }
  }

  Uint8List _imageToByteList(img.Image image, int width, int height) {
    // Resmi normalize ederek byte listesine dönüştür
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = img.getRed(pixel) / 255.0; // Normalize et
        buffer[pixelIndex++] = img.getGreen(pixel) / 255.0; // Normalize et
        buffer[pixelIndex++] = img.getBlue(pixel) / 255.0; // Normalize et
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  String _interpretGenderOutput(List<dynamic> probabilities) {
    // Cinsiyet tahminini yorumla
    if (probabilities[0] > probabilities[1]) {
      return "Women (${(probabilities[0] * 100).toStringAsFixed(2)}%)";
    } else {
      return "Man (${(probabilities[1] * 100).toStringAsFixed(2)}%)";
    }
  }
}