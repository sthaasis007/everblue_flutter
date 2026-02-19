import 'dart:io';

import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:everblue/features/auth/domain/usecases/delete_customer_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/login_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/logout_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/register_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:everblue/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;
  late final UpdateUserUsecase _updateUserUsecase;
  late final DeleteCustomerUsecase _deleteCustomerUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    _updateUserUsecase = ref.read(updateUserUsecaseProvider);
    _deleteCustomerUsecase = ref.read(deleteCustomerUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<String?> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadPhotoUsecase(photo);

    String? uploadedUrl;

    result.fold(
      (failure) {
        print('❌ Upload failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (url) {
        print('✅ Upload successful, received URL: $url');
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadedPhotoUrl: url,
        );
        uploadedUrl = url;
      },
    );

    // Save the profile picture filename to session for persistence if upload was successful
    if (uploadedUrl != null) {
      try {
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.updateUserProfilePicture(uploadedUrl!);
        print('✅ Profile picture saved to session: $uploadedUrl');
      } catch (e) {
        print('❌ Error saving profile picture to session: $e');
      }
    } else {
      print('❌ Upload returned null URL');
    }

    return uploadedUrl;
  }

  Future<bool> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _updateUserUsecase(
      UpdateUserParams(
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );

    return result.isRight();
  }

  Future<bool> deleteCustomer(String userId, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _deleteCustomerUsecase(
      DeleteCustomerParams(userId: userId, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );

    return result.isRight();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}