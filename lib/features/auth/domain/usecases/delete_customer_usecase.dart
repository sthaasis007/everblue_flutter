import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/auth/data/repositories/auth_repository.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteCustomerUsecaseProvider = Provider<DeleteCustomerUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return DeleteCustomerUsecase(repository: repository);
});

class DeleteCustomerParams {
  final String userId;
  final String password;

  DeleteCustomerParams({
    required this.userId,
    required this.password,
  });
}

class DeleteCustomerUsecase implements UsecaseWithParms<bool, DeleteCustomerParams> {
  final IAuthRepository _repository;

  DeleteCustomerUsecase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteCustomerParams params) async {
    return await _repository.deleteCustomer(params.userId, params.password);
  }
}
