import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/items/data/repositories/item_repository.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';
import 'package:everblue/features/items/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateItemParams extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final double price;
  final String status;
  final String? photoUrl;

  const UpdateItemParams({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.status,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, description, type, price, status, photoUrl];
}

final updateItemUsecaseProvider = Provider<UpdateItemUsecase>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return UpdateItemUsecase(repository: repository);
});

class UpdateItemUsecase
    implements UsecaseWithParms<ItemEntity, UpdateItemParams> {
  final IItemRepository _repository;

  UpdateItemUsecase({required IItemRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ItemEntity>> call(UpdateItemParams params) {
    final entity = ItemEntity(
      id: params.id,
      name: params.name,
      description: params.description,
      type: params.type,
      price: params.price,
      status: params.status,
      photoUrl: params.photoUrl,
    );
    return _repository.updateItem(params.id, entity);
  }
}
