import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

Future<File?> myImageCropper(String filePath) async {
  var croppedFile =
      await ImageCropper().cropImage(sourcePath: filePath, aspectRatioPresets: [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
  ]);

  final File imageFile = File(croppedFile!.path);
  return imageFile;
}
