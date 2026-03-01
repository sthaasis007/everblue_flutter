import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase getCurrentUserUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUsecase =
        GetCurrentUserUsecase(authRepository: mockAuthRepository);
  });

  const tAuthEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
  );

  group('GetCurrentUserUsecase', () {
    test('should return AuthEntity when getting current user is successful',
        () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when getting current user fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'User not found');
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
