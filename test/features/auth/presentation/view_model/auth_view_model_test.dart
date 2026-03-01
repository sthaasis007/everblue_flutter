import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/services/security/biometric_auth_service.dart';
import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/usecases/delete_customer_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/login_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/logout_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/register_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:everblue/features/auth/presentation/state/auth_state.dart';
import 'package:everblue/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}

class MockLogoutUsecaseImpl extends Mock implements LogoutUsecaseImpl {}

class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

class MockUpdateUserUsecase extends Mock implements UpdateUserUsecase {}

class MockDeleteCustomerUsecase extends Mock implements DeleteCustomerUsecase {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockFile extends Mock implements File {}

void main() {
  late ProviderContainer container;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecaseImpl mockLogoutUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockUpdateUserUsecase mockUpdateUserUsecase;
  late MockDeleteCustomerUsecase mockDeleteCustomerUsecase;
  late MockBiometricAuthService mockBiometricAuthService;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecaseImpl();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockUpdateUserUsecase = MockUpdateUserUsecase();
    mockDeleteCustomerUsecase = MockDeleteCustomerUsecase();
    mockBiometricAuthService = MockBiometricAuthService();
    mockUserSessionService = MockUserSessionService();

    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        getCurrentUserUsecaseProvider
            .overrideWithValue(mockGetCurrentUserUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
        updateUserUsecaseProvider.overrideWithValue(mockUpdateUserUsecase),
        deleteCustomerUsecaseProvider
            .overrideWithValue(mockDeleteCustomerUsecase),
        biometricAuthServiceProvider
            .overrideWithValue(mockBiometricAuthService),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
    );
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(
      email: 'test@example.com',
      password: 'password123',
    ));
    registerFallbackValue(const RegisterParams(
      fullName: 'Test User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      password: 'password123',
    ));
    registerFallbackValue(const UpdateUserParams(
      userId: '1',
      fullName: 'Updated Name',
    ));
    registerFallbackValue(DeleteCustomerParams(
      userId: '1',
      password: 'password123',
    ));
    registerFallbackValue(MockFile());
  });

  tearDown(() {
    container.dispose();
  });

  const tAuthEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
  );

  group('AuthViewModel', () {
    test('initial state should be AuthState with initial status', () {
      // Act
      final state = container.read(authViewModelProvider);

      // Assert
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('login should emit authenticated state when successful', () async {
      // Arrange
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));
      when(() => mockBiometricAuthService.saveLoginCredentials(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => {});

      // Act
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('login should emit error state when unsuccessful', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Invalid credentials');
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'test@example.com', password: 'wrong_password');

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('register should emit registered state when successful', () async {
      // Arrange
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      await container.read(authViewModelProvider.notifier).register(
            fullName: 'Test User',
            email: 'test@example.com',
            phoneNumber: '1234567890',
            password: 'password123',
          );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.registered);
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('register should emit error state when unsuccessful', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Email already exists');
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      await container.read(authViewModelProvider.notifier).register(
            fullName: 'Test User',
            email: 'test@example.com',
            phoneNumber: '1234567890',
            password: 'password123',
          );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email already exists');
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('logout should emit unauthenticated state when successful', () async {
      // Arrange
      when(() => mockLogoutUsecase())
          .thenAnswer((_) async => const Right(true));

      // Act
      await container.read(authViewModelProvider.notifier).logout();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      verify(() => mockLogoutUsecase()).called(1);
    });

    test('logout should emit error state when unsuccessful', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Logout failed');
      when(() => mockLogoutUsecase())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      await container.read(authViewModelProvider.notifier).logout();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Logout failed');
      verify(() => mockLogoutUsecase()).called(1);
    });

    test('getCurrentUser should emit authenticated state when successful',
        () async {
      // Arrange
      when(() => mockGetCurrentUserUsecase())
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await container.read(authViewModelProvider.notifier).getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
      verify(() => mockGetCurrentUserUsecase()).called(1);
    });

    test('updateUser should return true and update user when successful',
        () async {
      // Arrange
      const tUpdatedUser = AuthEntity(
        authId: '1',
        fullName: 'Updated Name',
        email: 'test@example.com',
        phoneNumber: '1234567890',
      );
      when(() => mockUpdateUserUsecase(any()))
          .thenAnswer((_) async => const Right(tUpdatedUser));

      // Act
      final result = await container
          .read(authViewModelProvider.notifier)
          .updateUser(userId: '1', fullName: 'Updated Name');

      // Assert
      expect(result, true);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUpdatedUser);
      verify(() => mockUpdateUserUsecase(any())).called(1);
    });

    test('deleteCustomer should return true when successful', () async {
      // Arrange
      when(() => mockDeleteCustomerUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await container
          .read(authViewModelProvider.notifier)
          .deleteCustomer('1', 'password123');

      // Assert
      expect(result, true);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      verify(() => mockDeleteCustomerUsecase(any())).called(1);
    });
  });
}
