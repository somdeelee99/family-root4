import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/family.dart';

/// ຈັດການຂໍ້ມູນຄອບຄົວ
class FamilyRepository {
  FamilyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// ສ້າງຄອບຄົວໃໝ່ (Admin ຜ່ານຂັ້ນຕອນສ້າງນາມສະກຸນ)
  Future<String> createFamily({
    required String surname,
    required String name,
    required String description,
    String? province,
    String? ownerId,
    String? coverUrl,
  }) async {
    final ref = _firestore.collection(FirestorePaths.families).doc();
    await ref.set(
      Family(
        id: ref.id,
        surname: surname.trim(),
        name: name.trim().isEmpty ? 'ຄອບຄົວ ${surname.trim()}' : name.trim(),
        description: description.trim(),
        province: province,
        ownerId: ownerId,
        coverUrl: coverUrl,
        memberCount: 0,
        createdAt: DateTime.now(),
      ).toMap(),
    );
    return ref.id;
  }

  Stream<Family?> familyStream(String familyId) {
    if (familyId.isEmpty) return Stream.value(null);
    return _firestore
        .doc(FirestorePaths.familyDoc(familyId))
        .snapshots()
        .map((doc) => doc.exists ? Family.fromDoc(doc) : null);
  }

  Future<Family?> fetchFamily(String familyId) async {
    if (familyId.isEmpty) return null;
    final doc = await _firestore.doc(FirestorePaths.familyDoc(familyId)).get();
    return doc.exists ? Family.fromDoc(doc) : null;
  }

  Future<void> updateFamily(
    String familyId, {
    String? surname,
    String? name,
    String? description,
    String? province,
    String? coverUrl,
  }) async {
    await _firestore.doc(FirestorePaths.familyDoc(familyId)).set({
      if (surname != null) 'surname': surname.trim(),
      if (name != null) 'name': name.trim(),
      if (description != null) 'description': description.trim(),
      if (province != null) 'province': province,
      if (coverUrl != null) 'coverUrl': coverUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ຖ້ານາມສະກຸນຊ້ຳກັບຄອບຄົວອື່ນທີ່ມີຢູ່ -> ເຂົ້າຮ່ວມຄອບຄົວນັ້ນ
  Future<String?> findFamilyIdBySurname(String surname) async {
    final snap = await _firestore
        .collection(FirestorePaths.families)
        .where('surname', isEqualTo: surname.trim())
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.id;
  }

  Future<void> incrementMemberCount(String familyId, {int delta = 1}) async {
    await _firestore.doc(FirestorePaths.familyDoc(familyId)).set({
      'memberCount': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ບັນທຶກການເຄື່ອນໄຫວ (audit log)
  Future<void> logActivity({
    required String familyId,
    required String userId,
    required String action,
    String? detail,
  }) async {
    await _firestore
        .collection(FirestorePaths.familyDoc(familyId) + '/activity')
        .add({
      'userId': userId,
      'action': action,
      'detail': detail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
