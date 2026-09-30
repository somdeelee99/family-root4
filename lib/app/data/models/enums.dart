import '../../core/constants/app_strings.dart';

/// ບົດບາດຜູ້ໃຊ້
/// - admin: ເຂົ້າລະບົບຜ່ານ Facebook / Google / Apple ເທົ່ານັ້ນ
/// - member: ບັນຊີທີ່ admin ສ້າງໃຫ້ (ອີແມວ + ລະຫັດຜ່ານ)
enum UserRole {
  admin,
  member;

  static UserRole fromString(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.member;

  String get value => name;
  bool get isAdmin => this == UserRole.admin;
  String get label => isAdmin ? AppStrings.roleAdmin : AppStrings.roleMember;
}

/// ສະຖານະຂອງສະມາຊິກໃນຜັງ
enum MemberStatus {
  alive,
  deceased,
  divorced;

  static MemberStatus fromString(String? value) {
    switch (value) {
      case 'deceased':
        return MemberStatus.deceased;
      case 'divorced':
        return MemberStatus.divorced;
      default:
        return MemberStatus.alive;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case MemberStatus.alive:
        return 'ຢູ່ (ຍັງມີຊີວິດ)';
      case MemberStatus.deceased:
        return 'ເສຍຊີວິດ';
      case MemberStatus.divorced:
        return 'ຢ່າຮ້າງ';
    }
  }

  String get shortLabel {
    switch (this) {
      case MemberStatus.alive:
        return 'ຢູ່';
      case MemberStatus.deceased:
        return 'ເສຍຊີວິດ';
      case MemberStatus.divorced:
        return 'ຢ່າຮ້າງ';
    }
  }
}

/// ເພດ
enum Gender {
  male,
  female,
  other;

  static Gender fromString(String? value) {
    switch (value) {
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case Gender.male:
        return AppStrings.male;
      case Gender.female:
        return AppStrings.female;
      case Gender.other:
        return 'ອື່ນໆ';
    }
  }
}

/// ຄວາມສຳພັນພາຍໃນຄອບຄົວ
enum RelationType {
  father,
  mother,
  son,
  daughter,
  spouse,
  brother,
  sister,
  sibling;

  static RelationType fromString(String? value) {
    for (final e in RelationType.values) {
      if (e.name == value) return e;
    }
    return RelationType.sibling;
  }

  String get value => name;

  String get label {
    switch (this) {
      case RelationType.father:
        return 'ພໍ່';
      case RelationType.mother:
        return 'ແມ່';
      case RelationType.son:
        return 'ລູກຊາຍ';
      case RelationType.daughter:
        return 'ລູກສາວ';
      case RelationType.spouse:
        return 'ຜົວ / ເມຍ';
      case RelationType.brother:
        return 'ອ້າຍ / ນ້ອງຊາຍ';
      case RelationType.sister:
        return 'ເອື້ອຍ / ນ້ອງສາວ';
      case RelationType.sibling:
        return 'ອ້າຍ / ເອື້ອຍ / ນ້ອງ';
    }
  }
}

/// ປະເພດຜູ້ໃຫ້ບໍລິການເຂົ້າລະບົບ
enum AuthProviderType {
  google,
  facebook,
  apple,
  password;

  static AuthProviderType fromString(String? value) {
    switch (value) {
      case 'google':
        return AuthProviderType.google;
      case 'facebook':
        return AuthProviderType.facebook;
      case 'apple':
        return AuthProviderType.apple;
      default:
        return AuthProviderType.password;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.facebook:
        return 'Facebook';
      case AuthProviderType.apple:
        return 'Apple';
      case AuthProviderType.password:
        return 'ອີແມວ / ລະຫັດຜ່ານ';
    }
  }
}
