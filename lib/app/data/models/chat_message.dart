import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'enums.dart';

/// ຂໍ້ຄວາມໃນການສົນທະນາ
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.senderRole = UserRole.member,
    this.text = '',
    this.imageUrl,
    this.type = 'text',
    this.createdAt,
    this.readBy = const [],
  });

  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final UserRole senderRole;
  final String text;
  final String? imageUrl;
  final String type;
  final DateTime? createdAt;
  final List<String> readBy;

  bool isMine(String uid) => senderId == uid;

  factory ChatMessage.fromMap(String id, String roomId, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: (map['senderId'] ?? '') as String,
      senderName: (map['senderName'] ?? '') as String,
      senderAvatar: map['senderAvatar'] as String?,
      senderRole: UserRole.fromString(map['senderRole'] as String?),
      text: (map['text'] ?? '') as String,
      imageUrl: map['imageUrl'] as String?,
      type: (map['type'] ?? 'text') as String,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(map['readBy'] as List? ?? const []),
    );
  }

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String roomId) =>
      ChatMessage.fromMap(doc.id, roomId, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'senderRole': senderRole.value,
        'text': text,
        'imageUrl': imageUrl,
        'type': type,
        'readBy': readBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// ແປງເປັນໂມເດລຂອງ flutter_chat_ui
  types.Message toChatUiMessage(String currentUserId) {
    final author = types.User(
      id: senderId,
      firstName: senderName,
      imageUrl: senderAvatar,
      role: senderRole.isAdmin ? types.Role.admin : types.Role.user,
    );
    if (type == 'image' && imageUrl != null) {
      return types.ImageMessage(
        id: id,
        author: author,
        uri: imageUrl!,
        name: 'image',
        size: 0,
        createdAt: createdAt?.millisecondsSinceEpoch,
      );
    }
    return types.TextMessage(
      id: id,
      author: author,
      text: text,
      createdAt: createdAt?.millisecondsSinceEpoch,
    );
  }
}
