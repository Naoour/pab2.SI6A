import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memilih gambar: $e');
    }
  }

  /// Convert image file to base64 string
  Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Gagal mengkonversi gambar ke base64: $e');
    }
  }

  /// Convert base64 string back to File (for temporary use)
  File base64ToFile(String base64String, String fileName) {
    try {
      final bytes = base64Decode(base64String);
      final file = File('${Directory.systemTemp.path}/$fileName');
      file.writeAsBytesSync(bytes);
      return file;
    } catch (e) {
      throw Exception('Gagal mengkonversi base64 ke gambar: $e');
    }
  }
}
