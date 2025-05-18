import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? fullName;
  final List<String>? preferredSubjects;

  const UserEntity({
    required this.id,
    this.email,
    this.fullName,
    this.preferredSubjects,
  });

  @override
  List<Object?> get props => [id, email, fullName, preferredSubjects];

  // Optional: Add a factory constructor for creating an empty/default user
  // static const empty = UserEntity(id: '');
  // bool get isEmpty => this == UserEntity.empty;
  // bool get isNotEmpty => this != UserEntity.empty;

  // Optional: Add copyWith method if needed
  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    List<String>? preferredSubjects,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
    );
  }
}
