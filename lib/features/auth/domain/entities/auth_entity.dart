import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;

  const AuthEntity({
    this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        password,
      ];
}