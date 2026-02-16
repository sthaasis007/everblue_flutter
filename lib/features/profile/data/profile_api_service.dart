import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApiService {
  final Dio _dio;
  final String baseUrl;

  ProfileApiService({Dio? dio, this.baseUrl = 'http://localhost:3000'}) : _dio = dio ?? Dio();

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  /// Uploads profile picture. Expects field name `profilePicture`.
  /// Returns photoUrl on success (e.g. `/public/profile_picture/profile_{userId}.jpg`).
  Future<String> uploadProfilePicture(File file) async {
    final token = await _getToken();
    final fileName = p.basename(file.path);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    });

    final response = await _dio.post(
      '$baseUrl/everblue/customers/upload-image',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        // Do not set content-type; Dio will set the multipart boundary
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['data'] is Map && data['data']['photoUrl'] != null) {
        String photoUrl = data['data']['photoUrl'] as String;
        // Add cache-busting query parameter to force image refresh
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        photoUrl = '$photoUrl?v=$timestamp';
        return photoUrl;
      }
      throw Exception('Unexpected response structure: $data');
    }
    throw Exception('Upload failed with status ${response.statusCode}');
  }
}

// Uses MediaType from `package:http_parser`
