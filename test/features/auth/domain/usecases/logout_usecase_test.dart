import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecaseImpl logoutUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUsecase = LogoutUsecaseImpl(authRepository: mockAuthRepository);
  });

  group('LogoutUsecase', () {
    test('should return true when logout is successful', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when logout fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Logout failed');
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
