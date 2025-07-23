import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class ProfilePicturePicker extends StatefulWidget {
  final void Function(File file) onImageSelected;

  const ProfilePicturePicker({super.key, required this.onImageSelected});

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _imageFile;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      widget.onImageSelected(file);

      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      widget.onImageSelected(File(croppedFile.path));
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(cameras: cameras),
      ),
    );
    if (result != null) {
      _cropImage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _imageFile != null
            ? Image.file(
                _imageFile!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.account_circle, size: 100),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload from Device'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _openCamera,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Selfie'),
        ),
      ],
    );
  }
}
