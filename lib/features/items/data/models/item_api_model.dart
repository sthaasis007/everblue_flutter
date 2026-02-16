import 'package:everblue/features/items/domain/entities/item_entity.dart';

class ItemApiModel {
  final String? id;
  final String name;
  final String description;
  final String type;
  final double price;
  final String status;
  final String? photoUrl;

  ItemApiModel({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.status,
    this.photoUrl,
  });

  factory ItemApiModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'];
    final rawName =
      json['itemName'] ?? json['name'] ?? json['title'] ?? '';
    final rawDescription =
      json['itemDescription'] ?? json['description'] ?? json['desc'] ?? '';
    final rawType = json['itemType'] ?? json['type'] ?? '';
    final rawStatus = json['itemStatus'] ?? json['status'] ?? 'available';
    final rawPhoto = json['image'] ??
      json['itemPhoto'] ??
      json['ItemPhoto'] ??
      json['photo'] ??
      json['photoUrl'];
    final rawPrice = json['itemPrice'] ?? json['price'];

    double priceValue = 0;
    if (rawPrice is num) {
      priceValue = rawPrice.toDouble();
    } else if (rawPrice is String) {
      priceValue = double.tryParse(rawPrice) ?? 0;
    }

    return ItemApiModel(
      id: rawId?.toString(),
      name: rawName.toString(),
      description: rawDescription.toString(),
      type: rawType.toString(),
      price: priceValue,
      status: rawStatus.toString(),
      photoUrl: rawPhoto?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final normalizedStatus = status.trim().toLowerCase();
    return {
      'itemName': name,
      'name': name,
      'itemDescription': description,
      'description': description,
      'itemType': type,
      'type': type,
      'itemPrice': price,
      'price': price,
      'itemStatus': normalizedStatus,
      'status': normalizedStatus,
      'image': photoUrl,
      'itemPhoto': photoUrl,
      'ItemPhoto': photoUrl,
    };
  }

  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      name: name,
      description: description,
      type: type,
      price: price,
      status: status,
      photoUrl: photoUrl,
    );
  }

  factory ItemApiModel.fromEntity(ItemEntity entity) {
    return ItemApiModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      price: entity.price,
      status: entity.status,
      photoUrl: entity.photoUrl,
    );
  }

  static List<ItemEntity> toEntityList(List<ItemApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
