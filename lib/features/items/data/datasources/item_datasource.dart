import 'dart:io';

import 'package:everblue/features/items/data/models/item_api_model.dart';

abstract interface class IItemRemoteDataSource {
  Future<String> uploadItemPhoto(File photo);
  Future<ItemApiModel> createItem(ItemApiModel item);
  Future<ItemApiModel> updateItem(String id, ItemApiModel item);
  Future<bool> deleteItem(String id);
  Future<List<ItemApiModel>> getItems({
    int? page,
    int? limit,
    String? type,
    String? status,
    double? price,
  });
}
