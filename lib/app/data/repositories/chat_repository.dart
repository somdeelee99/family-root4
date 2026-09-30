import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/enums.dart';

/// ຈັດການການສົນທະນາ (1:1), ການແຈ້ງເຕືອນ ແລະ ການນັບຂໍ້ຄວາມທີ່ຍັງບໍ່ອ່ານ
class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _rooms(String familyId) =>
      _firestore.collection(FirestorePaths.familyChats(familyId));

  CollectionReference<Map<String, dynamic>> _messages(
          String familyId, String roomId) =>
      _firestore.collection(FirestorePaths.chatMessages(familyId, roomId));

  /// ຫ້ອງສົນທະນາທັງໝົດຂອງຜູ້ໃຊ້ (ລຽງຕາມຂໍ້ຄວາມຫຼ້າສຸດ)
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

  /// ຂໍ້ຄວາມໃນຫ້ອງ (realtime)
  Stream<List<ChatMessage>> messagesStream(String familyId, String roomId,
      {int limit = 200}) {
    if (familyId.isEmpty || roomId.isEmpty) return Stream.value(const []);
    return _messages(familyId, roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromDoc(d, roomId))
            .toList()
            .reversed
            .toList());
  }

  /// ສ້າງ ຫຼື ເປີດຫ້ອງສົນທະນາກັບຜູ້ໃຊ້ອື່ນ
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

  /// ສົ່ງຂໍ້ຄວາມ + ອັບເດດຂໍ້ມູນຫ້ອງ ແລະ ນັບ unread ໃຫ້ຜູ້ຮັບ
  /// (ການແຈ້ງເຕືອນຈະຖືກສົ່ງອັດຕະໂນມັດຈາກ Cloud Function trigger)
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

    final otherUid =
        roomId.split('__').firstWhere((p) => p != senderId, orElse: () => '');

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

    await _rooms(familyId).doc(roomId).set({
      'participants': [senderId, otherUid]..sort(),
      'lastMessage': type == 'image' ? '📷 ຮູບພາບ' : trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
      'lastSenderName': senderName,
      if (otherUid.isNotEmpty) 'unread.$otherUid': FieldValue.increment(1),
      'unread.$senderId': 0,
    }, SetOptions(merge: true));
  }

  /// ໝາຍວ່າອ່ານແລ້ວ (ລົບ unread ຂອງຕົນເອງ)
  Future<void> markAsRead({
    required String familyId,
    required String roomId,
    required String uid,
  }) async {
    await _rooms(familyId).doc(roomId).set({
      'unread.$uid': 0,
    }, SetOptions(merge: true));
  }

  /// ຈຳນວນຂໍ້ຄວາມທີ່ຍັງບໍ່ອ່ານທັງໝົດ (badge ໃນແຖບລຸ່ມ)
  Stream<int> totalUnreadStream(String familyId, String myUid) {
    if (familyId.isEmpty) return Stream.value(0);
    return _rooms(familyId)
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) => snap.docs
            .map(ChatRoom.fromDoc)
            .fold<int>(0, (sum, room) => sum + room.unreadFor(myUid)));
  }

  /// ບັນທຶກການອ່ານຂໍ້ຄວາມ (readBy) - ບໍ່ອະນຸຍາດໃຫ້ລຶບຂໍ້ຄວາມ
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

  /// ລາຍຊື່ຜູ້ໃຊ້ທີ່ເຄີຍສົນທະນາກັນ ແລະ ຈຳນວນຂໍ້ຄວາມ
  Future<Map<String, int>> messageCountPerUser(String familyId) async {
    final snap = await _rooms(familyId).get();
    final map = <String, int>{};
    for (final doc in snap.docs) {
      final room = ChatRoom.fromDoc(doc);
      for (final uid in room.participants) {
        map.update(uid, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return map;
  }
}
