import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';

/// ຈັດການການລາຍງານ ແລະ ການບລັອກຜູ້ໃຊ້ (Play Store UGC requirement)
///
/// - `users/{uid}/blockedUsers/{blockedUid}` -> ຜູ້ທີ່ຂ້ອຍບລັອກ (ອ່ານ/ຂຽນໄດ້ສະເພາະເຈົ້າຂອງ)
/// - `reports/{reportId}`                   -> ລາຍງານເນື້ອຫາ/ຜູ້ໃຊ້ (ຂຽນໄດ້ຢ່າງດຽວ, ອ່ານບໍ່ໄດ້ຈາກ client)
class ModerationRepository {
  ModerationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _blockedUsers(String uid) =>
      _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.blockedUsers);

  /// ລາຍຊື່ uid ທີ່ຂ້ອຍບລັອກໄວ້ (real-time)
  Stream<Set<String>> blockedUidsStream(String uid) {
    if (uid.isEmpty) return Stream.value(<String>{});
    return _blockedUsers(uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.id).toSet());
  }

  Future<void> blockUser({
    required String myUid,
    required String blockedUid,
    String? blockedName,
  }) async {
    if (myUid.isEmpty || blockedUid.isEmpty) return;
    await _blockedUsers(myUid).doc(blockedUid).set({
      'blockedUid': blockedUid,
      'blockedName': blockedName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser({
    required String myUid,
    required String blockedUid,
  }) async {
    if (myUid.isEmpty || blockedUid.isEmpty) return;
    await _blockedUsers(myUid).doc(blockedUid).delete();
  }

  /// ສົ່ງລາຍງານໄປໃຫ້ທີມຜູ້ດູແລ (ເກັບໄວ້ໃນ Firestore, ອ່ານຈາກ client ບໍ່ໄດ້)
  Future<void> reportUser({
    required String familyId,
    required String reporterId,
    required String reportedUid,
    required String reason,
    String? details,
    String? roomId,
    String? messageId,
  }) async {
    if (reporterId.isEmpty || reportedUid.isEmpty) return;
    await _firestore.collection(FirestorePaths.reports).add({
      'familyId': familyId,
      'reporterId': reporterId,
      'reportedUid': reportedUid,
      'reason': reason,
      'details': (details ?? '').trim(),
      'roomId': roomId,
      'messageId': messageId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'open',
    });
  }
}
