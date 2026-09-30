import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/services/cloud_function_service.dart';
import '../models/app_user.dart';
import '../models/enums.dart';

/// ຈັດການບັນຊີສະມາຊິກ (ໜ້າສະມາຊິກ - ສຳລັບ admin ສ້າງບັນຊີ)
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  /// ລາຍຊື່ຜູ້ໃຊ້ທັງໝົດໃນຄອບຄົວດຽວກັນ
  Stream<List<AppUser>> usersStream(String familyId) {
    if (familyId.isEmpty) return Stream.value(const []);
    return _users
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(AppUser.fromDoc).toList();
      list.sort((a, b) {
        if (a.role != b.role) return a.role.isAdmin ? -1 : 1;
        return a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase());
      });
      return list;
    });
  }

  /// ຜູ້ໃຊ້ອື່ນໆ ທັງໝົດ ຍົກເວັ້ນຕົນເອງ (ໃຊ້ໃນໜ້າແຊັດ ແລະ ລາຍຊື່)
  Stream<List<AppUser>> othersStream(String familyId, String myUid) {
    if (familyId.isEmpty) return Stream.value(const []);
    return _users
        .where('familyId', isEqualTo: familyId)
        .where('uid', isNotEqualTo: myUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(AppUser.fromDoc).toList();
      list.sort((a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
      return list;
    });
  }

  Future<AppUser?> fetch(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Future<Map<String, AppUser>> fetchMap(List<String> uids) async {
    if (uids.isEmpty) return {};
    final result = <String, AppUser>{};
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, min(i + 10, uids.length));
      final snap =
          await _users.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        result[doc.id] = AppUser.fromDoc(doc);
      }
    }
    return result;
  }

  // ================= ສ້າງບັນຊີ member (Admin ເທົ່ານັ້ນ) =================

  /// ສ້າງບັນຊີໃໝ່ໃຫ້ສະມາຊິກ
  ///
  /// 1) ພະຍາຍາມເອີ້ນ Cloud Function `createMemberAccount` (ວິທີທີ່ປອດໄພສຸດ -
  ///    admin ບໍ່ຕ້ອງອອກຈາກລະບົບ)
  /// 2) ຖ້າຍັງບໍ່ deploy function ຈະໃຊ້ວິທີສຳຮອງ: ສ້າງດ້ວຍ FirebaseApp ຮອງ
  ///    (secondary app) ແລ້ວກັບມາໃຊ້ session ຂອງ admin ຄືເກົ່າ
  Future<String> createMemberAccount({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String familyId,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    String? memberId,
    String? surname,
  }) async {
    var newUid = await CloudFunctionService.instance.createMemberAccount(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      familyId: familyId,
      phone: phone,
      whatsapp: whatsapp,
      avatarUrl: avatarUrl,
      birthDate: birthDate,
      gender: gender,
    );

    if (newUid == null) {
      newUid = await _createWithSecondaryAuth(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        familyId: familyId,
        phone: phone,
        whatsapp: whatsapp,
        avatarUrl: avatarUrl,
        birthDate: birthDate,
        gender: gender,
        memberId: memberId,
        surname: surname,
      );
      return newUid;
    }

    // ຖ້າໃຊ້ Cloud Function ສຳເລັດ ອັບເດດຂໍ້ມູນເພີ່ມເຕີມທີ່ function ບໍ່ໄດ້ຮັບ
    await _users.doc(newUid).set({
      if (memberId != null) 'memberId': memberId,
      if (surname != null) 'surname': surname,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return newUid;
  }

  /// ວິທີສຳຮອງ: ໃຊ້ FirebaseApp ຮອງ ເພື່ອບໍ່ໃຫ້ session ຂອງ admin ຖືກປ່ຽນ
  Future<String> _createWithSecondaryAuth({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String familyId,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    String? memberId,
    String? surname,
  }) async {
    const secondaryName = 'member_creator';
    FirebaseApp? secondaryApp;
    try {
      try {
        secondaryApp = Firebase.app(secondaryName);
      } on FirebaseException {
        secondaryApp = await Firebase.initializeApp(
          name: secondaryName,
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final newUid = credential.user!.uid;

      await credential.user!.updateDisplayName(displayName);
      if (avatarUrl != null) await credential.user!.updatePhotoURL(avatarUrl);

      // ຂຽນຂໍ້ມູນຜູ້ໃຊ້ດ້ວຍ session ຂອງ admin ທີ່ຍັງຄົງຢູ່
      await _users.doc(newUid).set(
            AppUser(
              uid: newUid,
              displayName: displayName.trim(),
              email: email.trim(),
              phone: phone,
              whatsapp: whatsapp,
              avatarUrl: avatarUrl,
              role: UserRole.fromString(role),
              familyId: familyId,
              surname: surname,
              birthDate: birthDate,
              gender: gender,
              memberId: memberId,
              providers: const [AuthProviderType.password],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ).toMap(),
          );

      await secondaryAuth.signOut();
      return newUid;
    } finally {
      try {
        await Firebase.app(secondaryName).delete();
      } catch (_) {
        // ຂ້າມຖ້າລຶບບໍ່ໄດ້
      }
    }
  }

  /// ອັບເດດບັນຊີສະມາຊິກ (admin ເທົ່ານັ້ນ - ລວມທັງປ່ຽນ role)
  Future<void> updateMemberAccount({
    required String uid,
    String? displayName,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    UserRole? role,
    String? surname,
    DateTime? birthDate,
    String? gender,
    bool? isActive,
    String? memberId,
  }) async {
    await _users.doc(uid).set({
      if (displayName != null) 'displayName': displayName.trim(),
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role.value,
      if (surname != null) 'surname': surname,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      if (gender != null) 'gender': gender,
      if (isActive != null) 'isActive': isActive,
      if (memberId != null) 'memberId': memberId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ລຶບບັນຊີສະມາຊິກ (ລຶບໃນ Firestore ແລະ ພະຍາຍາມລຶບໃນ Firebase Auth ຜ່ານ Cloud Function)
  Future<void> deleteMemberAccount(String uid, {String? familyId}) async {
    await _users.doc(uid).delete();
    await CloudFunctionService.instance.deleteUserAccount(uid);
    if (familyId != null) {
      await _firestore.doc(FirestorePaths.familyDoc(familyId)).set({
        'memberCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));
    }
  }

  /// ຜູ້ໃຊ້ທີ່ຍັງບໍ່ໄດ້ຢູ່ໃນຄອບຄົວໃດ (ຕ້ອງການສ້າງ/ເຂົ້າຄອບຄົວ)
  Stream<List<AppUser>> pendingUsersStream() => _users
      .where('familyId', isNull: true)
      .snapshots()
      .map((snap) => snap.docs.map(AppUser.fromDoc).toList());

  /// ນາມສະກຸນທີ່ຖືກໃຊ້ແລ້ວ (ກວດສອບການຊ້ຳ)
  Future<bool> surnameExists(String surname) async {
    final snap = await _firestore
        .collection(FirestorePaths.families)
        .where('surname', isEqualTo: surname.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Debug helper
  @visibleForTesting
  String encodePasswordInfo(String password) =>
      base64Encode(utf8.encode(password));
}
