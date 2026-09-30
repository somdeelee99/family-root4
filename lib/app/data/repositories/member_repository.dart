import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/enums.dart';
import '../models/family_member.dart';

/// ຈັດການສະມາຊິກໃນຜັງໄມ້ຄອບຄົວ (nodes ແລະ ຄວາມສຳພັນ)
class MemberRepository {
  MemberRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  CollectionReference<Map<String, dynamic>> _col(String familyId) =>
      _firestore.collection(FirestorePaths.familyMembers(familyId));

  /// ສະມາຊິກທັງໝົດໃນຜັງ (realtime)
  Stream<List<FamilyMember>> membersStream(String familyId) {
    if (familyId.isEmpty) return Stream.value(const []);
    return _col(familyId).orderBy('generation').snapshots().map((snap) =>
        snap.docs.map((d) => FamilyMember.fromDoc(d, familyId)).toList());
  }

  Future<List<FamilyMember>> fetchAll(String familyId) async {
    if (familyId.isEmpty) return [];
    final snap = await _col(familyId).orderBy('generation').get();
    return snap.docs.map((d) => FamilyMember.fromDoc(d, familyId)).toList();
  }

  Future<FamilyMember?> fetch(String familyId, String memberId) async {
    final doc = await _col(familyId).doc(memberId).get();
    return doc.exists ? FamilyMember.fromDoc(doc, familyId) : null;
  }

  // ============================ ເພີ່ມ ============================
  Future<String> addMember({
    required String familyId,
    required String fullName,
    String? nickname,
    String? avatarUrl,
    Gender gender = Gender.male,
    MemberStatus status = MemberStatus.alive,
    int generation = 1,
    DateTime? birthDate,
    DateTime? deathDate,
    String? phone,
    String? whatsapp,
    String? email,
    String? occupation,
    String? address,
    String? note,
    String? fatherId,
    String? motherId,
    List<String> spouseIds = const [],
    List<String> childIds = const [],
    String? createdBy,
    String? linkedUserId,
  }) async {
    final ref = _col(familyId).doc();
    final member = FamilyMember(
      id: ref.id,
      familyId: familyId,
      fullName: fullName.trim(),
      nickname: nickname,
      avatarUrl: avatarUrl,
      gender: gender,
      status: status,
      generation: generation,
      birthDate: birthDate,
      deathDate: deathDate,
      phone: phone,
      whatsapp: whatsapp,
      email: email,
      occupation: occupation,
      address: address,
      note: note,
      fatherId: fatherId,
      motherId: motherId,
      spouseIds: spouseIds,
      childIds: childIds,
      linkedUserId: linkedUserId,
      isAccountHolder: linkedUserId != null,
      createdBy: createdBy,
    );
    await ref.set(member.toMap());

    // ອັບເດດຄວາມສຳພັນແບບສອງທາງ (bidirectional)
    await _syncRelations(familyId: familyId, memberId: ref.id, member: member);

    await _firestore.doc(FirestorePaths.familyDoc(familyId)).set({
      'memberCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return ref.id;
  }

  // ============================ ແກ້ໄຂ ============================
  Future<void> updateMember({
    required String familyId,
    required String memberId,
    String? fullName,
    String? nickname,
    String? avatarUrl,
    Gender? gender,
    MemberStatus? status,
    int? generation,
    DateTime? birthDate,
    DateTime? deathDate,
    String? phone,
    String? whatsapp,
    String? email,
    String? occupation,
    String? address,
    String? note,
    String? fatherId,
    String? motherId,
    List<String>? spouseIds,
    List<String>? childIds,
    bool clearFather = false,
    bool clearMother = false,
    bool clearDeathDate = false,
  }) async {
    final previous = await fetch(familyId, memberId);

    final updated = previous?.copyWith(
          fullName: fullName,
          nickname: nickname,
          avatarUrl: avatarUrl,
          gender: gender,
          status: status,
          generation: generation,
          birthDate: birthDate,
          deathDate: deathDate,
          phone: phone,
          whatsapp: whatsapp,
          email: email,
          occupation: occupation,
          address: address,
          note: note,
          fatherId: fatherId,
          motherId: motherId,
          spouseIds: spouseIds,
          childIds: childIds,
          clearFather: clearFather,
          clearMother: clearMother,
          clearDeathDate: clearDeathDate,
        ) ??
        FamilyMember(
          id: memberId,
          familyId: familyId,
          fullName: fullName ?? '',
        );

    await _col(familyId)
        .doc(memberId)
        .set(updated.toMap(), SetOptions(merge: true));
    await _syncRelations(
        familyId: familyId, memberId: memberId, member: updated);
  }

  /// ລຶບສະມາຊິກ ພ້ອມແກ້ໄຂຄວາມສຳພັນທີ່ອ້າງອີງເຖິງ
  Future<void> deleteMember({
    required String familyId,
    required String memberId,
    required List<FamilyMember> allMembers,
  }) async {
    final batch = _firestore.batch();

    for (final m in allMembers) {
      if (m.id == memberId) continue;

      final updates = <String, dynamic>{};
      if (m.fatherId == memberId) updates['fatherId'] = null;
      if (m.motherId == memberId) updates['motherId'] = null;
      if (updates.isEmpty &&
          !m.spouseIds.contains(memberId) &&
          !m.childIds.contains(memberId) &&
          !m.siblingIds.contains(memberId)) {
        continue;
      }
      updates['spouseIds'] = FieldValue.arrayRemove([memberId]);
      updates['childIds'] = FieldValue.arrayRemove([memberId]);
      updates['siblingIds'] = FieldValue.arrayRemove([memberId]);
      updates['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(_col(familyId).doc(m.id), updates, SetOptions(merge: true));
    }

    batch.delete(_col(familyId).doc(memberId));
    await batch.commit();

    await _firestore.doc(FirestorePaths.familyDoc(familyId)).set({
      'memberCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ຜູກຄວາມສຳພັນສອງທາງ: ພໍ່ແມ່ <-> ລູກ, ຜົວເມຍ, ອ້າຍເອື້ອຍນ້ອງ
  Future<void> _syncRelations({
    required String familyId,
    required String memberId,
    required FamilyMember member,
  }) async {
    final batch = _firestore.batch();
    final col = _col(familyId);

    // ພໍ່ / ແມ່ -> ເພີ່ມລູກ
    for (final parentId in [member.fatherId, member.motherId]) {
      if (parentId == null || parentId.isEmpty) continue;
      batch.set(
          col.doc(parentId),
          {
            'childIds': FieldValue.arrayUnion([memberId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    // ຜົວ/ເມຍ
    for (final spouseId in member.spouseIds) {
      if (spouseId.isEmpty) continue;
      batch.set(
          col.doc(spouseId),
          {
            'spouseIds': FieldValue.arrayUnion([memberId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    // ລູກ -> ຕື່ມພໍ່ແມ່ຖ້າຍັງບໍ່ມີ
    for (final childId in member.childIds) {
      if (childId.isEmpty) continue;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (member.gender == Gender.male) {
        updates['fatherId'] = memberId;
      } else {
        updates['motherId'] = memberId;
      }
      batch.set(col.doc(childId), updates, SetOptions(merge: true));
      // ລູກຕ້ອງຢູ່ລຸ້ນຖັດໄປຢ່າງໜ້ອຍ
      batch.set(
          col.doc(childId),
          {
            'generation': member.generation + 1,
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// ສະຖິຕິຂອງຄອບຄົວ (ໜ້າຫຼັກ)
  static FamilyStats calculateStats(List<FamilyMember> members) {
    var male = 0, female = 0, deceased = 0, under18 = 0, divorced = 0;
    final generations = <int, int>{};

    for (final m in members) {
      if (m.gender == Gender.female) {
        female++;
      } else if (m.gender == Gender.male) {
        male++;
      }
      if (m.status == MemberStatus.deceased) deceased++;
      if (m.status == MemberStatus.divorced) divorced++;
      if (m.isUnder18) under18++;
      generations.update(m.generation, (v) => v + 1, ifAbsent: () => 1);
    }

    return FamilyStats(
      total: members.length,
      male: male,
      female: female,
      deceased: deceased,
      under18: under18,
      divorced: divorced,
      alive: members.length - deceased,
      generations: generations,
    );
  }
}

/// ຜົນສະຖິຕິ
class FamilyStats {
  const FamilyStats({
    required this.total,
    required this.male,
    required this.female,
    required this.deceased,
    required this.under18,
    required this.divorced,
    required this.alive,
    required this.generations,
  });

  final int total;
  final int male;
  final int female;
  final int deceased;
  final int under18;
  final int divorced;
  final int alive;
  final Map<int, int> generations;

  static const FamilyStats empty = FamilyStats(
    total: 0,
    male: 0,
    female: 0,
    deceased: 0,
    under18: 0,
    divorced: 0,
    alive: 0,
    generations: {},
  );

  double percent(int value) => total == 0 ? 0 : value / total;

  int get maxGeneration => generations.isEmpty
      ? 1
      : generations.keys.reduce((a, b) => a > b ? a : b);
}
