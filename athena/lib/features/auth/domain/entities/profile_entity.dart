import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? website;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.website,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, website, updatedAt];

  // Default empty profile
  static const empty = ProfileEntity(id: '');

  //copyWith
  ProfileEntity copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? website,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 