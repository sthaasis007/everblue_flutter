import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  setUpAll(() {
    registerFallbackValue(const AuthEntity(
      fullName: 'Test User',
      email: 'test@example.com',
    ));
  });

  const tRegisterParams = RegisterParams(
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
    password: 'password123',
  );

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await registerUsecase(tRegisterParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when registration fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Email already exists');
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await registerUsecase(tRegisterParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.register(any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
