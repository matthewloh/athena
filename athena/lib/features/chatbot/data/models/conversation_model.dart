import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  final int? messageCount;
  final Map<String, dynamic>? metadata;

  const ConversationModel({
    required super.id,
    required super.userId,
    super.title,
    required super.createdAt,
    required super.updatedAt,
    super.lastMessageSnippet,
    this.messageCount,
    this.metadata,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageSnippet: json['last_message_snippet'] as String?,
      messageCount: json['message_count'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_snippet': lastMessageSnippet,
      'metadata': metadata ?? {},
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // Let database generate ID
    json.remove('created_at'); // Let database set timestamp
    json.remove('updated_at'); // Let database set timestamp
    json.remove('last_message_snippet'); // Will be set by trigger
    return json;
  }

  @override
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageSnippet,
    int? messageCount,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
      messageCount: messageCount ?? this.messageCount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [...super.props, messageCount, metadata];
}
