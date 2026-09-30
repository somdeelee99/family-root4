import 'package:cloud_firestore/cloud_firestore.dart';

/// ຫ້ອງສົນທະນາ 1:1 ລະຫວ່າງສະມາຊິກສອງຄົນ
class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageAt,
    this.lastSenderId,
    this.lastSenderName,
    this.unread = const {},
    this.createdAt,
  });

  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final String? lastSenderName;

  /// uid -> ຈຳນວນຂໍ້ຄວາມທີ່ຍັງບໍ່ອ່ານ
  final Map<String, int> unread;

  final DateTime? createdAt;

  String otherParty(String myUid) =>
      participants.firstWhere((p) => p != myUid, orElse: () => participants.first);

  int unreadFor(String uid) => unread[uid] ?? 0;

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    final rawUnread = map['unread'] as Map<String, dynamic>? ?? const {};
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants'] as List? ?? const []),
      lastMessage: (map['lastMessage'] ?? '') as String,
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: map['lastSenderId'] as String?,
      lastSenderName: map['lastSenderName'] as String?,
      unread: rawUnread.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0)),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ChatRoom.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ChatRoom.fromMap(doc.id, doc.data() ?? const {});
}
