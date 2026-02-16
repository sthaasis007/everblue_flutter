import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/services/connecitvity/network_info.dart';
import 'package:everblue/features/items/data/datasources/item_datasource.dart';
import 'package:everblue/features/items/data/datasources/remote/item_remote_datasource.dart';
import 'package:everblue/features/items/data/models/item_api_model.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';
import 'package:everblue/features/items/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemRepositoryProvider = Provider<IItemRepository>((ref) {
  final remoteDataSource = ref.read(itemRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ItemRepository(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

class ItemRepository implements IItemRepository {
  final IItemRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ItemRepository({
    required IItemRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, String>> uploadItemPhoto(File photo) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final url = await _remoteDataSource.uploadItemPhoto(photo);
      return Right(url);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: _extractErrorMessage(e.response?.data, 'Upload failed'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> createItem(ItemEntity item) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final model = ItemApiModel.fromEntity(item);
      final created = await _remoteDataSource.createItem(model);
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: _extractErrorMessage(e.response?.data, 'Create item failed'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItem(String id, ItemEntity item) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final model = ItemApiModel.fromEntity(item);
      final updated = await _remoteDataSource.updateItem(id, model);
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: _extractErrorMessage(e.response?.data, 'Update item failed'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteItem(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final result = await _remoteDataSource.deleteItem(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: _extractErrorMessage(e.response?.data, 'Delete item failed'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems({
    int? page,
    int? limit,
    String? type,
    String? status,
    double? price,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getItems(
        page: page,
        limit: limit,
        type: type,
        status: status,
        price: price,
      );
      return Right(ItemApiModel.toEntityList(models));
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: _extractErrorMessage(e.response?.data, 'Fetch items failed'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return fallback;
  }
}
