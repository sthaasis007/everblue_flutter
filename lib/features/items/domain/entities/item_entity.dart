import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String? id;
  final String name;
  final String description;
  final String type;
  final double price;
  final String status;
  final String? photoUrl;

  const ItemEntity({
    this.id,
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
