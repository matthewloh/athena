import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String userId;
  final String? title; // Optional: could be auto-generated or user-set
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessageSnippet; // For display in a list

  const ConversationEntity({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageSnippet,
  });

  @override
  List<Object?> get props => [id, userId, title, createdAt, updatedAt, lastMessageSnippet];

  ConversationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageSnippet,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
    );
  }
} 