import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UpdateUserUsecase updateUserUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    updateUserUsecase = UpdateUserUsecase(repository: mockAuthRepository);
  });

  const tUserId = '1';
  const tUpdateParams = UpdateUserParams(
    userId: tUserId,
    fullName: 'Updated Name',
    email: 'updated@example.com',
  );

  const tUpdatedAuthEntity = AuthEntity(
    authId: tUserId,
    fullName: 'Updated Name',
    email: 'updated@example.com',
    phoneNumber: '1234567890',
  );

  group('UpdateUserUsecase', () {
    test('should return updated AuthEntity when update is successful',
        () async {
      // Arrange
      when(() => mockAuthRepository.updateUser(tUserId, any()))
          .thenAnswer((_) async => const Right(tUpdatedAuthEntity));

      // Act
      final result = await updateUserUsecase(tUpdateParams);

      // Assert
      expect(result, const Right(tUpdatedAuthEntity));
      verify(() => mockAuthRepository.updateUser(tUserId, any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when update fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Update failed');
      when(() => mockAuthRepository.updateUser(tUserId, any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await updateUserUsecase(tUpdateParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.updateUser(tUserId, any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
