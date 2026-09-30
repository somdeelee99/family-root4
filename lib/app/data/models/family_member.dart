import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// ບຸກຄົນໃນຜັງໄມ້ຄອບຄົວ (node)
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.familyId,
    required this.fullName,
    this.nickname,
    this.avatarUrl,
    this.gender = Gender.male,
    this.status = MemberStatus.alive,
    this.generation = 1,
    this.birthDate,
    this.deathDate,
    this.phone,
    this.whatsapp,
    this.email,
    this.occupation,
    this.address,
    this.note,
    this.fatherId,
    this.motherId,
    this.spouseIds = const [],
    this.childIds = const [],
    this.siblingIds = const [],
    this.linkedUserId,
    this.isAccountHolder = false,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String familyId;
  final String fullName;
  final String? nickname;
  final String? avatarUrl;
  final Gender gender;
  final MemberStatus status;
  final int generation;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? occupation;
  final String? address;
  final String? note;

  // ---- ຄວາມສຳພັນ ----
  final String? fatherId;
  final String? motherId;
  final List<String> spouseIds;
  final List<String> childIds;
  final List<String> siblingIds;

  /// ຜູກກັບບັນຊີຜູ້ໃຊ້ (ຖ້າສະມາຊິກຄົນນີ້ມີບັນຊີເຂົ້າລະບົບ)
  final String? linkedUserId;
  final bool isAccountHolder;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDeceased => status == MemberStatus.deceased;
  bool get isDivorced => status == MemberStatus.divorced;

  int get ageInYears {
    if (birthDate == null) return 0;
    final end = deathDate ?? DateTime.now();
    var years = end.year - birthDate!.year;
    if (end.month < birthDate!.month ||
        (end.month == birthDate!.month && end.day < birthDate!.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  bool get isUnder18 => birthDate != null && ageInYears < 18;

  String get genderLabel => gender.label;
  String get statusLabel => status.shortLabel;

  String get generationLabel => 'ລຸ້ນທີ $generation';

  String get displayName {
    final nick = nickname?.trim() ?? '';
    return nick.isEmpty ? fullName : '$fullName ($nick)';
  }

  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  factory FamilyMember.fromMap(String id, String familyId, Map<String, dynamic> map) {
    return FamilyMember(
      id: id,
      familyId: (map['familyId'] ?? familyId) as String,
      fullName: (map['fullName'] ?? '') as String,
      nickname: map['nickname'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      gender: Gender.fromString(map['gender'] as String?),
      status: MemberStatus.fromString(map['status'] as String?),
      generation: (map['generation'] as num?)?.toInt() ?? 1,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      deathDate: (map['deathDate'] as Timestamp?)?.toDate(),
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      email: map['email'] as String?,
      occupation: map['occupation'] as String?,
      address: map['address'] as String?,
      note: map['note'] as String?,
      fatherId: map['fatherId'] as String?,
      motherId: map['motherId'] as String?,
      spouseIds: List<String>.from(map['spouseIds'] as List? ?? const []),
      childIds: List<String>.from(map['childIds'] as List? ?? const []),
      siblingIds: List<String>.from(map['siblingIds'] as List? ?? const []),
      linkedUserId: map['linkedUserId'] as String?,
      isAccountHolder: map['isAccountHolder'] as bool? ?? false,
      createdBy: map['createdBy'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory FamilyMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String familyId) =>
      FamilyMember.fromMap(doc.id, familyId, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'id': id,
        'familyId': familyId,
        'fullName': fullName,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'gender': gender.value,
        'status': status.value,
        'generation': generation,
        if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
        if (deathDate != null) 'deathDate': Timestamp.fromDate(deathDate!),
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'occupation': occupation,
        'address': address,
        'note': note,
        'fatherId': fatherId,
        'motherId': motherId,
        'spouseIds': spouseIds,
        'childIds': childIds,
        'siblingIds': siblingIds,
        'linkedUserId': linkedUserId,
        'isAccountHolder': isAccountHolder,
        'createdBy': createdBy,
        'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  FamilyMember copyWith({
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
    List<String>? siblingIds,
    String? linkedUserId,
    bool? isAccountHolder,
    bool clearFather = false,
    bool clearMother = false,
    bool clearDeathDate = false,
  }) {
    return FamilyMember(
      id: id,
      familyId: familyId,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      generation: generation ?? this.generation,
      birthDate: birthDate ?? this.birthDate,
      deathDate: clearDeathDate ? null : (deathDate ?? this.deathDate),
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      note: note ?? this.note,
      fatherId: clearFather ? null : (fatherId ?? this.fatherId),
      motherId: clearMother ? null : (motherId ?? this.motherId),
      spouseIds: spouseIds ?? this.spouseIds,
      childIds: childIds ?? this.childIds,
      siblingIds: siblingIds ?? this.siblingIds,
      linkedUserId: linkedUserId ?? this.linkedUserId,
      isAccountHolder: isAccountHolder ?? this.isAccountHolder,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
