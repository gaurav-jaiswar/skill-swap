import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:skill_swap/utils/toast.dart';
import 'package:skill_swap/widgets/loading_popup.dart';

class CloudinaryHelper {
  CloudinaryHelper._();

  static Future<String?> pickAndGetLink(
    BuildContext context, {
    bool cropImage = false,
  }) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedImage != null) {
      if (cropImage) {
        final file = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.square,
              toolbarTitle: 'Cropper',
              toolbarColor: Color.fromRGBO(58, 58, 58, 1),
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
          ],
        );
        if (file != null) {
          return await uploadImage(context, file.path);
        }
      } else {
        return await uploadImage(context, pickedImage.path);
      }
    }
    return null;
  }

  static Future<String?> uploadImage(
    BuildContext context,
    String filePath,
  ) async {
    showLoadingPopup(context, "Uploading...");
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/df6ihcyjs/upload');
      final request =
          MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'default'
            ..files.add(await MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseJson = jsonDecode(String.fromCharCodes(responseData));
        return responseJson['url'];
      }
    } on ClientException {
      Toast.showToast(message: "Unstable Internet", isError: true);
    }
    return null;
  }

  static Future<void> deleteImage(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(publicId, timestamp);

    try {
      final response = await post(
        Uri.parse('https://api.cloudinary.com/v1_1/df6ihcyjs/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'signature': signature,
          'api_key': dotenv.env['CLOUDINARY_API_KEY'],
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (kDebugMode) {
          print(result);
        }
        if (result['result'] == 'ok') {
          if (kDebugMode) {
            print('Image deleted successfully!');
          }
        } else {
          if (kDebugMode) {
            print('Failed to delete image: ${result['error']}');
          }
        }
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } on ClientException {
      Toast.showToast(message: "Unstable Internet", isError: true);
    }
  }

  static String _generateSignature(String publicId, int timestamp) {
    final data =
        'public_id=$publicId&timestamp=$timestamp${dotenv.env['CLOUDINARY_API_SECRET']}';
    return sha1.convert(utf8.encode(data)).toString();
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (8, 3);

  @override
  String get name => '8:3';
}
