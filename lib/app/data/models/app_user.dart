import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// ບັນຊີຜູ້ໃຊ້ແອັບ (ທັງ admin ແລະ member)
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.phone,
    this.whatsapp,
    this.avatarUrl,
    this.role = UserRole.member,
    this.familyId,
    this.surname,
    this.birthDate,
    this.gender,
    this.memberId,
    this.providers = const [],
    this.fcmToken,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastSeenAt,
  });

  final String uid;
  final String displayName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? avatarUrl;
  final UserRole role;
  final String? familyId;
  final String? surname;
  final DateTime? birthDate;
  final String? gender;

  /// ຜູກກັບ node ໃນຜັງໄມ້ຄອບຄົວ (ຖ້າມີ)
  final String? memberId;

  final List<AuthProviderType> providers;
  final String? fcmToken;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeenAt;

  bool get isAdmin => role.isAdmin;
  bool get hasFamily => (familyId ?? '').isNotEmpty;
  bool get isProfileComplete => (displayName.trim().isNotEmpty) && hasFamily;

  String get initials {
    final name = displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters_first;
    return '${parts.first.characters_first}${parts.last.characters_first}';
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      displayName: (map['displayName'] ?? map['name'] ?? '') as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      role: UserRole.fromString(map['role'] as String?),
      familyId: map['familyId'] as String?,
      surname: map['surname'] as String?,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      gender: map['gender'] as String?,
      memberId: map['memberId'] as String?,
      providers: (map['providers'] as List<dynamic>? ?? const [])
          .map((e) => AuthProviderType.fromString(e as String?))
          .toList(),
      fcmToken: map['fcmToken'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      lastSeenAt: (map['lastSeenAt'] as Timestamp?)?.toDate(),
    );
  }

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      AppUser.fromMap(doc.id, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'whatsapp': whatsapp,
        'avatarUrl': avatarUrl,
        'role': role.value,
        'familyId': familyId,
        'surname': surname,
        if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
        'gender': gender,
        'memberId': memberId,
        'providers': providers.map((e) => e.value).toList(),
        'fcmToken': fcmToken,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
        if (lastSeenAt != null) 'lastSeenAt': Timestamp.fromDate(lastSeenAt!),
      };

  AppUser copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    UserRole? role,
    String? familyId,
    String? surname,
    DateTime? birthDate,
    String? gender,
    String? memberId,
    List<AuthProviderType>? providers,
    String? fcmToken,
    bool? isActive,
    DateTime? lastSeenAt,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      memberId: memberId ?? this.memberId,
      providers: providers ?? this.providers,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

extension on String {
  /// ຕົວອັກສອນທຳອິດຂອງຊື່ (ຮອງຮັບ Unicode/ລາວ)
  String get characters_first => isEmpty ? '?' : substring(0, 1).toUpperCase();
}
