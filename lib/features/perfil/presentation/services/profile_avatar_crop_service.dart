import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CroppedProfileAvatar {
  final Uint8List bytes;
  final String extension;

  const CroppedProfileAvatar({required this.bytes, required this.extension});
}

class ProfileAvatarCropService {
  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  ProfileAvatarCropService({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _imageCropper = imageCropper ?? ImageCropper();

  Future<CroppedProfileAvatar?> pickAndCrop(BuildContext context) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    if (!context.mounted) return null;

    final cropped = await _imageCropper.cropImage(
      sourcePath: picked.path,
      maxWidth: 900,
      maxHeight: 900,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar foto',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.white,
          cropFrameColor: Colors.white,
          cropGridColor: Colors.white,
          showCropGrid: true,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Ajustar foto',
          doneButtonTitle: 'Usar',
          cancelButtonTitle: 'Cancelar',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        WebUiSettings(
          context: context,
          translations: const WebTranslations(
            title: 'Ajustar foto',
            rotateLeftTooltip: 'Girar para esquerda',
            rotateRightTooltip: 'Girar para direita',
            cancelButton: 'Cancelar',
            cropButton: 'Usar',
          ),
        ),
      ],
    );
    if (cropped == null) return null;

    return CroppedProfileAvatar(
      bytes: await cropped.readAsBytes(),
      extension: 'jpg',
    );
  }
}
