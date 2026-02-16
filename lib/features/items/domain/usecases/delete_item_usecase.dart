import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/items/data/repositories/item_repository.dart';
import 'package:everblue/features/items/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteItemParams extends Equatable {
  final String id;

  const DeleteItemParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final deleteItemUsecaseProvider = Provider<DeleteItemUsecase>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return DeleteItemUsecase(repository: repository);
});

class DeleteItemUsecase implements UsecaseWithParms<bool, DeleteItemParams> {
  final IItemRepository _repository;

  DeleteItemUsecase({required IItemRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteItemParams params) {
    return _repository.deleteItem(params.id);
  }
}
