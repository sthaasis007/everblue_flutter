import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase loginUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: tEmail,
    phoneNumber: '1234567890',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await loginUsecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Invalid credentials');
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await loginUsecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
