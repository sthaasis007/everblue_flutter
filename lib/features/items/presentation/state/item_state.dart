import 'package:equatable/equatable.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';

enum ItemStatus {
  initial,
  loading,
  fetching,
  uploading,
  loaded,
  creating,
  created,
  updating,
  deleting,
  error,
}

class ItemState extends Equatable {
  final ItemStatus status;
  final List<ItemEntity> items;
  final String? errorMessage;

  const ItemState({
    this.status = ItemStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  ItemState copyWith({
    ItemStatus? status,
    List<ItemEntity>? items,
    String? errorMessage,
  }) {
    return ItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
