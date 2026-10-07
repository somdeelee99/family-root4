import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/enums.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _rooms(String familyId) =>
      _firestore.collection(FirestorePaths.familyChats(familyId));

  CollectionReference<Map<String, dynamic>> _messages(
    String familyId,
    String roomId,
  ) => _firestore.collection(FirestorePaths.chatMessages(familyId, roomId));

  Stream<List<ChatRoom>> roomsStream(String familyId, String myUid) {
    if (familyId.isEmpty) return Stream.value(const []);
    return _rooms(familyId)
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) {
          final rooms = snap.docs.map(ChatRoom.fromDoc).toList()
            ..sort((a, b) {
              final at = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
              final bt = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
              return bt.compareTo(at);
            });
          return rooms;
        });
  }

  Stream<List<ChatMessage>> messagesStream(
    String familyId,
    String roomId, {
    int limit = 200,
  }) {
    if (familyId.isEmpty || roomId.isEmpty) return Stream.value(const []);
    return _messages(familyId, roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromDoc(d, roomId))
              .toList()
              .reversed
              .toList(),
        );
  }

  Future<String> openRoom({
    required String familyId,
    required String myUid,
    required String otherUid,
  }) async {
    final roomId = FirestorePaths.chatRoomId(myUid, otherUid);
    final ref = _rooms(familyId).doc(roomId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': [myUid, otherUid]..sort(),
        'lastMessage': '',
        'unread': {myUid: 0, otherUid: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }

  // *** ແກ້ແລ້ວ: ບໍ່ສົ່ງ participants ອີກ ***
  Future<void> sendMessage({
    required String familyId,
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    UserRole senderRole = UserRole.member,
    required String text,
    String? imageUrl,
    String type = 'text',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageUrl == null) return;
    final otherUid = roomId
        .split('__')
        .firstWhere((p) => p != senderId, orElse: () => '');

    await _messages(familyId, roomId).add(
      ChatMessage(
        id: '',
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        senderRole: senderRole,
        text: trimmed,
        imageUrl: imageUrl,
        type: type,
      ).toMap(),
    );

    // ใช้ update ไม่ใช่ set + ไม่ส่ง participants
    await _rooms(familyId).doc(roomId).update({
      'lastMessage': type == 'image' ? '📷 ຮູບພາບ' : trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
      'lastSenderName': senderName,
      if (otherUid.isNotEmpty) 'unread.$otherUid': FieldValue.increment(1),
      'unread.$senderId': 0,
    });
  }

  Future<void> markAsRead({
    required String familyId,
    required String roomId,
    required String uid,
  }) async {
    await _rooms(familyId).doc(roomId).update({'unread.$uid': 0});
  }

  Stream<int> totalUnreadStream(String familyId, String myUid) {
    if (familyId.isEmpty) return Stream.value(0);
    return _rooms(familyId)
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(ChatRoom.fromDoc)
              .fold<int>(0, (sum, room) => sum + room.unreadFor(myUid)),
        );
  }

  Future<void> markMessageRead({
    required String familyId,
    required String roomId,
    required String messageId,
    required String uid,
  }) async {
    await _messages(familyId, roomId).doc(messageId).set({
      'readBy': FieldValue.arrayUnion([uid]),
    }, SetOptions(merge: true));
  }
}
