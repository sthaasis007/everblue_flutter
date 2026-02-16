import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';

abstract interface class IItemRepository {
  Future<Either<Failure, String>> uploadItemPhoto(File photo);
  Future<Either<Failure, ItemEntity>> createItem(ItemEntity item);
  Future<Either<Failure, ItemEntity>> updateItem(String id, ItemEntity item);
  Future<Either<Failure, bool>> deleteItem(String id);
  Future<Either<Failure, List<ItemEntity>>> getItems({
    int? page,
    int? limit,
    String? type,
    String? status,
    double? price,
  });
}
