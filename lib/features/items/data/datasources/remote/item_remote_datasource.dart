import 'dart:io';

import 'package:dio/dio.dart';
import 'package:everblue/core/api/api_client.dart';
import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/features/items/data/datasources/item_datasource.dart';
import 'package:everblue/features/items/data/models/item_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemRemoteDatasourceProvider = Provider<IItemRemoteDataSource>((ref) {
  return ItemRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ItemRemoteDatasource implements IItemRemoteDataSource {
  final ApiClient _apiClient;

  ItemRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<String> uploadItemPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'ItemPhoto': await MultipartFile.fromFile(photo.path, filename: fileName),
    });

    try {
      final response = await _apiClient.uploadFile(
        ApiEndpoints.itemUploadPhoto,
        formData: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      var photoUrl = _extractPhotoUrl(response.data);
      if (photoUrl == null) {
        throw Exception('No photo url in response: ${response.data}');
      }
      
      // Add cache-busting query parameter to force image refresh
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      photoUrl = '$photoUrl?v=$timestamp';
      
      return photoUrl;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      var fallbackUrl = _extractPhotoUrl(errorData);
      if (fallbackUrl != null) {
        print('⚠️ Upload returned error but photoUrl found: $fallbackUrl');
        // Add cache-busting timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fallbackUrl = '$fallbackUrl?v=$timestamp';
        return fallbackUrl;
      }

      print('❌ Item photo upload failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<ItemApiModel> createItem(ItemApiModel item) async {
    final response = await _apiClient.post(
      ApiEndpoints.itemCreate,
      data: item.toJson(),
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    if (payload.isEmpty) {
      throw Exception('Invalid create item response: ${response.data}');
    }

    return ItemApiModel.fromJson(payload);
  }

  @override
  Future<ItemApiModel> updateItem(String id, ItemApiModel item) async {
    final response = await _apiClient.put(
      ApiEndpoints.itemUpdate(id),
      data: item.toJson(),
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    if (payload.isEmpty) {
      return ItemApiModel.fromEntity(item.toEntity());
    }

    return ItemApiModel.fromJson(payload);
  }

  @override
  Future<bool> deleteItem(String id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.itemDelete(id),
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success is bool) return success;
    }

    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<List<ItemApiModel>> getItems({
    int? page,
    int? limit,
    String? type,
    String? status,
    double? price,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.items,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (type != null && type.isNotEmpty) 'type': type,
        if (status != null && status.isNotEmpty) 'status': status,
        if (price != null) 'price': price,
      },
    );

    final data = response.data;
    final list = _extractList(data);
    return list.map(ItemApiModel.fromJson).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List) {
        return payload.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  String? _extractPhotoUrl(dynamic data) {
    if (data is String && data.isNotEmpty) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final direct = _findPhotoKey(data);
      if (direct != null) return direct;
      final payload = data['data'];
      if (payload is String && payload.isNotEmpty) {
        return payload;
      }
      if (payload is Map<String, dynamic>) {
        return _findPhotoKey(payload);
      }
    }
    return null;
  }

  String? _findPhotoKey(Map<String, dynamic> data) {
    final keys = [
      'photoUrl',
      'itemPhoto',
      'photo',
      'image',
      'path',
      'ItemPhoto',
    ];
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
