import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/delete_customer_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late DeleteCustomerUsecase deleteCustomerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    deleteCustomerUsecase =
        DeleteCustomerUsecase(repository: mockAuthRepository);
  });

  const tUserId = '1';
  const tPassword = 'password123';
  final tDeleteParams = DeleteCustomerParams(
    userId: tUserId,
    password: tPassword,
  );

  group('DeleteCustomerUsecase', () {
    test('should return true when customer deletion is successful', () async {
      // Arrange
      when(() => mockAuthRepository.deleteCustomer(tUserId, tPassword))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await deleteCustomerUsecase(tDeleteParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.deleteCustomer(tUserId, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when customer deletion fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Deletion failed');
      when(() => mockAuthRepository.deleteCustomer(tUserId, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await deleteCustomerUsecase(tDeleteParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.deleteCustomer(tUserId, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
