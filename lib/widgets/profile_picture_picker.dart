import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  void _openCameraApp() {
    if (Platform.isWindows) {
      Process.run('start', ['microsoft.windows.camera:', ''], runInShell: true);
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
          onPressed: _openCameraApp,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Selfie (Open Camera App)'),
        ),
      ],
    );
  }
}
