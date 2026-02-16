import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/items/data/repositories/item_repository.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';
import 'package:everblue/features/items/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetItemsParams extends Equatable {
  final int? page;
  final int? limit;
  final String? type;
  final String? status;
  final double? price;

  const GetItemsParams({
    this.page,
    this.limit,
    this.type,
    this.status,
    this.price,
  });

  @override
  List<Object?> get props => [page, limit, type, status, price];
}

final getItemsUsecaseProvider = Provider<GetItemsUsecase>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return GetItemsUsecase(repository: repository);
});

class GetItemsUsecase implements UsecaseWithParms<List<ItemEntity>, GetItemsParams> {
  final IItemRepository _repository;

  GetItemsUsecase({required IItemRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<ItemEntity>>> call(GetItemsParams params) {
    return _repository.getItems(
      page: params.page,
      limit: params.limit,
      type: params.type,
      status: params.status,
      price: params.price,
    );
  }
}
