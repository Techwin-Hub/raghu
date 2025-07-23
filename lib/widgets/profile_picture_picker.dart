import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'take_selfie.dart';

class ProfilePicturePicker extends StatefulWidget {
  final void Function(File file)? onImageSelected;
  final void Function(Uint8List imageBytes)? onWebImageSelected;

  const ProfilePicturePicker({
    super.key,
    this.onImageSelected,
    this.onWebImageSelected,
  });

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  final CropController _cropController = CropController();
  Uint8List? _webImageBytes;
  File? _pickedFile;
  bool _showCropper = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _showCropper = true;
        });
      } else {
        final file = File(pickedFile.path);
        setState(() {
          _pickedFile = file;
          _showCropper = true;
        });
      }
    }
  }

  void _onCropped(Uint8List croppedData) {
    if (kIsWeb) {
      widget.onWebImageSelected?.call(croppedData);
      setState(() {
        _webImageBytes = croppedData;
        _showCropper = false;
      });
    } else {
      // Save cropped image to temp file (optional)
      // For now, reuse same file reference
      widget.onImageSelected?.call(_pickedFile!);
      setState(() {
        _showCropper = false;
      });
    }
  }

  Widget _imagePreview() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, width: 100, height: 100, fit: BoxFit.cover);
    } else if (_pickedFile != null) {
      return Image.file(_pickedFile!, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.account_circle, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _imagePreview(),
        const SizedBox(height: 10),
        if (_showCropper && (kIsWeb ? _webImageBytes != null : _pickedFile != null))
          SizedBox(
            height: 300,
            child: Crop(
              controller: _cropController,
              image: kIsWeb
                  ? _webImageBytes!
                  : File(_pickedFile!.path).readAsBytesSync(),
              onCropped: _onCropped,
              initialSize: 0.8,
              baseColor: Colors.white,
              maskColor: Colors.black.withOpacity(0.4),
              cornerDotBuilder: (size, edgeAlignment) =>
                  const DotControl(color: Colors.orange),
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload from Device'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            if (kIsWeb) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Take a Selfie"),
                  content: SizedBox(
                    width: 400,
                    height: 500,
                    child: TakeSelfieWebWidget(
                      onCropped: (croppedBytes) {
                        widget.onWebImageSelected?.call(croppedBytes);
                        setState(() {
                          _webImageBytes = croppedBytes;
                          _showCropper = false;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              );
            } else {
              _pickImage(ImageSource.camera);
            }
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Selfie'),
        ),
      ],
    );
  }
}
