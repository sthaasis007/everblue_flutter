import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';
import 'package:everblue/features/items/domain/usecases/create_item_usecase.dart';
import 'package:everblue/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:everblue/features/items/domain/usecases/get_items_usecase.dart';
import 'package:everblue/features/items/domain/usecases/update_item_usecase.dart';
import 'package:everblue/features/items/domain/usecases/upload_item_photo_usecase.dart';
import 'package:everblue/features/items/presentation/state/item_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemViewModelProvider = NotifierProvider<ItemViewModel, ItemState>(
  ItemViewModel.new,
);

class ItemViewModel extends Notifier<ItemState> {
  late final UploadItemPhotoUsecase _uploadItemPhotoUsecase;
  late final CreateItemUsecase _createItemUsecase;
  late final GetItemsUsecase _getItemsUsecase;
  late final UpdateItemUsecase _updateItemUsecase;
  late final DeleteItemUsecase _deleteItemUsecase;

  @override
  ItemState build() {
    _uploadItemPhotoUsecase = ref.read(uploadItemPhotoUsecaseProvider);
    _createItemUsecase = ref.read(createItemUsecaseProvider);
    _getItemsUsecase = ref.read(getItemsUsecaseProvider);
    _updateItemUsecase = ref.read(updateItemUsecaseProvider);
    _deleteItemUsecase = ref.read(deleteItemUsecaseProvider);
    return const ItemState();
  }

  Future<String?> uploadItemPhoto(File photo) async {
    state = state.copyWith(status: ItemStatus.uploading);

    final result = await _uploadItemPhotoUsecase(
      UploadItemPhotoParams(photo: photo),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () => const Left(ApiFailure(message: 'Upload timed out')),
    );

    String? uploadedUrl;

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ItemStatus.error,
          errorMessage: failure.message,
        );
      },
      (url) {
        uploadedUrl = url;
        state = state.copyWith(status: ItemStatus.loaded);
      },
    );

    return uploadedUrl;
  }

  Future<ItemEntity?> createItem({
    required String name,
    required String description,
    required String type,
    required double price,
    required String status,
    String? photoUrl,
  }) async {
    state = state.copyWith(status: ItemStatus.creating);

    final result = await _createItemUsecase(
      CreateItemParams(
        name: name,
        description: description,
        type: type,
        price: price,
        status: status,
        photoUrl: photoUrl,
      ),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () => const Left(ApiFailure(message: 'Create item timed out')),
    );

    ItemEntity? createdItem;

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ItemStatus.error,
          errorMessage: failure.message,
        );
      },
      (item) {
        createdItem = item;
        state = state.copyWith(
          status: ItemStatus.created,
          items: [item, ...state.items],
        );
      },
    );

    return createdItem;
  }

  Future<void> getItems({
    int? page,
    int? limit,
    String? type,
    String? status,
    double? price,
  }) async {
    state = state.copyWith(status: ItemStatus.fetching);

    final result = await _getItemsUsecase(
      GetItemsParams(
        page: page,
        limit: limit,
        type: type,
        status: status,
        price: price,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ItemStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: ItemStatus.loaded,
          items: items,
        );
      },
    );
  }

  Future<ItemEntity?> updateItem({
    required String id,
    required String name,
    required String description,
    required String type,
    required double price,
    required String status,
    String? photoUrl,
  }) async {
    state = state.copyWith(status: ItemStatus.updating);

    final result = await _updateItemUsecase(
      UpdateItemParams(
        id: id,
        name: name,
        description: description,
        type: type,
        price: price,
        status: status,
        photoUrl: photoUrl,
      ),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () => const Left(ApiFailure(message: 'Update item timed out')),
    );

    ItemEntity? updatedItem;

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ItemStatus.error,
          errorMessage: failure.message,
        );
      },
      (item) {
        updatedItem = item;
        final updatedItems = state.items
            .map((existing) => existing.id == item.id ? item : existing)
            .toList();
        state = state.copyWith(status: ItemStatus.loaded, items: updatedItems);
      },
    );

    return updatedItem;
  }

  Future<bool> deleteItem(String id) async {
    state = state.copyWith(status: ItemStatus.deleting);

    final result = await _deleteItemUsecase(
      DeleteItemParams(id: id),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () => const Left(ApiFailure(message: 'Delete item timed out')),
    );

    bool deleted = false;

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ItemStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        deleted = success;
        if (success) {
          final updatedItems =
              state.items.where((item) => item.id != id).toList();
          state = state.copyWith(status: ItemStatus.loaded, items: updatedItems);
        } else {
          state = state.copyWith(status: ItemStatus.loaded);
        }
      },
    );

    return deleted;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
