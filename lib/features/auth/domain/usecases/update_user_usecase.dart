import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/auth/data/repositories/auth_repository.dart';
import 'package:everblue/features/auth/domain/entities/auth_entity.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateUserParams extends Equatable {
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? password;

  const UpdateUserParams({
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (fullName != null) data['name'] = fullName;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (password != null) data['password'] = password;
    return data;
  }

  @override
  List<Object?> get props => [userId, fullName, email, phoneNumber, password];
}

final updateUserUsecaseProvider = Provider<UpdateUserUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UpdateUserUsecase(repository: repository);
});

class UpdateUserUsecase implements UsecaseWithParms<AuthEntity, UpdateUserParams> {
  final IAuthRepository _repository;

  UpdateUserUsecase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateUserParams params) async {
    return await _repository.updateUser(params.userId, params.toJson());
  }
}
