import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/profile_api_service.dart';

typedef UploadCallback = void Function(String photoUrl);

class ProfilePictureUploader extends StatefulWidget {
  final UploadCallback? onUploaded;
  final int maxFileSizeBytes;

  const ProfilePictureUploader({Key? key, this.onUploaded, this.maxFileSizeBytes = 10000000}) : super(key: key);

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  bool _isUploading = false;
  final _service = ProfileApiService();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final fileSize = await file.length();
    if (fileSize > widget.maxFileSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File size exceeds 10 MB')));
      return;
    }

    final lower = picked.path.toLowerCase();
    if (!(lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.gif'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid file type. Allowed: jpg, jpeg, png, gif')));
      return;
    }

    setState(() => _selectedFile = file);
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() => _isUploading = true);
    try {
      final photoUrl = await _service.uploadProfilePicture(_selectedFile!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful')));
      widget.onUploaded?.call(photoUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: _selectedFile == null
              ? CircleAvatar(radius: 48, child: Icon(Icons.camera_alt, size: 32))
              : CircleAvatar(radius: 48, backgroundImage: FileImage(_selectedFile!)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: (_selectedFile != null && !_isUploading) ? _upload : null,
              icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
              label: const Text('Upload'),
            ),
          ],
        ),
      ],
    );
  }
}
