import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/services/connecitvity/network_info.dart';
import 'package:everblue/features/auth/data/datasources/auth_datasource.dart';
import 'package:everblue/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:everblue/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:everblue/features/auth/data/models/auth_api_model.dart';
import 'package:everblue/features/auth/data/models/auth_hive_model.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository{

  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authDataSource = authDatasource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
    
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid email or password"));
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data?['message'] ?? 'Login failed',
          statusCode: e.response?.statusCode,
          ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data?['message'] ?? 'Registration failed',
          statusCode: e.response?.statusCode,
          ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }else {
      try {
        // Check if email already exists
        final existingUser = await _authDataSource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }
        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          password: user.password,
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDataSource.uploadPhoto(image);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.updateUser(userId, data);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Failed to update user"));
      } on DioException catch (e) {
        String errorMessage = 'Update failed';
        
        // Handle MongoDB duplicate key error (E11000)
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          if (message != null && message.contains('E11000')) {
            if (message.contains('email')) {
              errorMessage = 'Email already in use';
            } else if (message.contains('phoneNumber')) {
              errorMessage = 'Phone number already in use';
            } else {
              errorMessage = 'This information is already in use';
            }
          } else {
            errorMessage = message ?? 'Update failed';
          }
        }
        
        return Left(ApiFailure(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomer(String userId, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.deleteCustomer(userId, password);
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: "Failed to delete account"));
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data?['message'] ?? 'Failed to delete account',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}