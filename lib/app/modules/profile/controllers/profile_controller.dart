import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/cloud_function_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FamilyRepository _familyRepo = FamilyRepository();
  final MemberRepository _memberRepo = MemberRepository();

  StreamSubscription<Family?>? _familySub;
  StreamSubscription<List<FamilyMember>>? _membersSub;

  final Rxn<Family> family = Rxn<Family>();
  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxBool notificationsEnabled = true.obs;

  AuthService get auth => AuthService.to;
  bool get isAdmin => auth.isAdmin;
  bool get isDark => ThemeService.to.isDark.value;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    final fid = auth.familyId;
    if (fid.isEmpty) return;
    _familySub = _familyRepo
        .familyStream(fid)
        .listen((value) => family.value = value);
    _membersSub = _memberRepo
        .membersStream(fid)
        .listen((list) => members.assignAll(list));
  }

  int get totalMembers => members.length;
  int get generationCount {
    if (members.isEmpty) return 0;
    return members.map((m) => m.generation).toSet().length;
  }

  Future<void> toggleNotifications() async {
    notificationsEnabled.value = !notificationsEnabled.value;
    if (notificationsEnabled.value) {
      await NotificationService.instance.subscribeToFamily(auth.familyId);
      UiHelpers.success('ເປີດການແຈ້ງເຕືອນແລ້ວ');
    } else {
      await NotificationService.instance.unsubscribeFromFamily(auth.familyId);
      UiHelpers.info('ປິດການແຈ້ງເຕືອນແລ້ວ');
    }
  }

  void toggleTheme() => ThemeService.to.toggle();

  void goToEditProfile() => Get.toNamed(Routes.EDIT_PROFILE);

  void goToFamilyInfo() => Get.toNamed(Routes.FAMILY_INFO);

  // Play Store ຕ້ອງການ privacy policy URL ທີ່ເຂົ້າເຖິງໄດ້.
  static const String privacyPolicyUrl =
      'https://familyroot-26df8.web.app/privacy.html';
  static const String termsUrl =
      'https://familyroot-26df8.web.app/terms.html';

  Future<void> openPrivacyPolicy() => _openUrl(privacyPolicyUrl);

  Future<void> openTerms() => _openUrl(termsUrl);

  Future<void> _openUrl(String url) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) UiHelpers.error('ບໍ່ສາມາດເປີດລິ້ງໄດ້');
    } catch (_) {
      UiHelpers.error('ບໍ່ສາມາດເປີດລິ້ງໄດ້');
    }
  }

  Future<void> signOut() async {
    final confirmed = await UiHelpers.confirm(
      title: 'ອອກຈາກລະບົບ',
      message: 'ທ່ານຕ້ອງການອອກຈາກລະບົບແທ້ບໍ?',
      confirmText: 'ອອກ',
      isDanger: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed != true) return; // <--- สำคัญ

    try {
      await _familySub?.cancel();
      await _membersSub?.cancel();
    } catch (_) {}

    try {
      await auth.signOut();
    } finally {
      Get.offAllNamed(Routes.AUTH);
    }
  }

  /// ລຶບບັນຊີຂອງຕົນເອງ ແລະ ຂໍ້ມູນສ່ວນຕົວ (Play Store requirement)
  Future<void> deleteMyAccount() async {
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບບັນຊີຂອງຂ້ອຍ?',
      message:
          'ບັນຊີ, ຂໍ້ມູນສ່ວນຕົວ ແລະ ຮູບໂປຣໄຟລ໌ຈະຖືກລຶບຖາວອນ. '
          'ຂໍ້ຄວາມໃນການສົນທະນາອາດຖືກເກັບໄວ້ເພື່ອຄວາມສົມບູນຂອງປະຫວັດຄອບຄົວ.',
      confirmText: 'ລຶບບັນຊີ',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed) return;

    UiHelpers.loading(message: 'ກຳລັງລຶບບັນຊີ...');
    try {
      await CloudFunctionService.instance.deleteMyAccount();
      UiHelpers.hideLoading();
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
      return;
    }

    try {
      await _familySub?.cancel();
      await _membersSub?.cancel();
      await auth.signOut();
    } catch (_) {
      // ບັນຊີຖືກລຶບແລ້ວ - ພຽງແຕ່ໄປໜ້າເຂົ້າລະບົບ
    } finally {
      Get.offAllNamed(Routes.AUTH);
      UiHelpers.success('ລຶບບັນຊີສຳເລັດ');
    }
  }

  /// ປ່ຽນ role ຂອງຕົນເອງບໍ່ໄດ້ - ສະເພາະ Admin ອື່ນກຳນົດໃຫ້
  String get roleDescription => isAdmin
      ? 'ທ່ານເຂົ້າລະບົບຜ່ານ ${_providerLabels()} - ມີສິດຈັດການຄອບຄົວທັງໝົດ'
      : 'ບັນຊີຂອງທ່ານຖືກສ້າງໂດຍ Admin ດ້ວຍອີແມວ ແລະ ລະຫັດຜ່ານ';

  String _providerLabels() {
    final providers = auth.user.value?.providers ?? const <AuthProviderType>[];
    if (providers.isEmpty) return 'ໂຊເຊຍ';
    return providers.map((p) => p.label).join(', ');
  }

  @override
  void onClose() {
    _familySub?.cancel();
    _membersSub?.cancel();
    super.onClose();
  }
}
