import 'package:cloud_firestore/cloud_firestore.dart';

/// ຂໍ້ມູນຄອບຄົວ
class Family {
  const Family({
    required this.id,
    required this.surname,
    this.name = '',
    this.description = '',
    this.province,
    this.coverUrl,
    this.ownerId,
    this.memberCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// ນາມສະກຸນ (ຈຳເປັນຕ້ອງມີ)
  final String surname;

  /// ຊື່ຄອບຄົວ
  final String name;

  /// ລາຍລະອຽດຄອບຄົວ
  final String description;

  final String? province;
  final String? coverUrl;
  final String? ownerId;
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName => name.trim().isNotEmpty ? name : 'ຄອບຄົວ $surname';

  factory Family.fromMap(String id, Map<String, dynamic> map) => Family(
        id: id,
        surname: (map['surname'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        province: map['province'] as String?,
        coverUrl: map['coverUrl'] as String?,
        ownerId: map['ownerId'] as String?,
        memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory Family.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Family.fromMap(doc.id, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'surname': surname,
        'name': name,
        'description': description,
        'province': province,
        'coverUrl': coverUrl,
        'ownerId': ownerId,
        'memberCount': memberCount,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
