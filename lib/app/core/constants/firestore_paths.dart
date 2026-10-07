/// ໂຄງສ້າງຖານຂໍ້ມູນ Firestore ຂອງ Family Root
///
/// users/{uid}                                 -> ບັນຊີຜູ້ໃຊ້ແອັບ (admin | member)
/// families/{familyId}                         -> ຂໍ້ມູນຄອບຄົວ (ນາມສະກຸນ, ລາຍລະອຽດ)
/// families/{familyId}/members/{memberId}      -> ບຸກຄົນໃນຜັງໄມ້ຄອບຄົວ
/// families/{familyId}/chats/{roomId}          -> ຫ້ອງແຊັດ
/// families/{familyId}/chats/{roomId}/messages/{messageId} -> ຂໍ້ຄວາມ
/// families/{familyId}/activity/{logId}        -> ບັນທຶກການເຄື່ອນໄຫວ (audit log)
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String families = 'families';
  static const String members = 'members';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String activity = 'activity';
  static const String notifications = 'notifications';

  static String userDoc(String uid) => '$users/$uid';
  static String familyDoc(String familyId) => '$families/$familyId';
  static String familyMembers(String familyId) =>
      '$families/$familyId/$members';
  static String memberDoc(String familyId, String memberId) =>
      '$families/$familyId/$members/$memberId';
  static String familyChats(String familyId) => '$families/$familyId/$chats';
  static String chatMessages(String familyId, String roomId) =>
      '$families/$familyId/$chats/$roomId/$messages';

  /// roomId = uid ສອງຄົນຮຽງລຳດັບແລ້ວຕໍ່ກັນ (ຮັບປະກັນວ່າຫ້ອງດຽວກັນສະເໝີ)
  static String chatRoomId(String uidA, String uidB) {
    final list = [uidA, uidB]..sort();
    return '${list.first}__${list.last}';
  }
}
