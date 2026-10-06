import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

/// ຂັ້ນຕອນສ້າງຄອບຄົວ ສຳລັບ Admin (ຕ້ອງປ້ອນນາມສະກຸນກ່ອນຈຶ່ງຈະສ້າງໄດ້)
class FamilySetupController extends GetxController {
  final FamilyRepository _familyRepo = FamilyRepository();
  final MemberRepository _memberRepo = MemberRepository();
  final UserRepository _userRepo = UserRepository();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxString surnameError = ''.obs;
  final RxBool canSubmit = false.obs; // <-- ແກ້ຈຸດນີ້ ໃຫ້ເປັນ Rx

  @override
  void onInit() {
    super.onInit();
    surnameController.addListener(_updateCanSubmit);
    ever(isSubmitting, (_) => _updateCanSubmit());
    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    canSubmit.value =
        surnameController.text.trim().isNotEmpty && !isSubmitting.value;
    if (surnameController.text.trim().isNotEmpty) {
      surnameError.value = '';
    }
  }

  Future<void> createFamily() async {
    if (surnameController.text.trim().isEmpty) {
      surnameError.value = AppStrings.surnameRequired;
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;
    UiHelpers.loading(message: 'ກຳລັງສ້າງຄອບຄົວ...');

    try {
      final auth = AuthService.to;
      final surname = surnameController.text.trim();

      // ຖ້ານາມສະກຸນຊ້ຳກັບຄອບຄົວທີ່ມີຢູ່ -> ເຂົ້າຮ່ວມຄອບຄົວນັ້ນ
      final existing = await _familyRepo.findFamilyIdBySurname(surname);
      final familyId =
          existing ??
          await _familyRepo.createFamily(
            surname: surname,
            name: nameController.text.trim(),
            description: descriptionController.text.trim(),
            province: provinceController.text.trim(),
            ownerId: auth.uid,
          );

      await auth.attachFamily(familyId, surname: surname);

      // ສ້າງ node ຂອງ admin ເອງໃນຜັງ (ລຸ້ນທີ 1)
      if (auth.user.value != null) {
        final member = auth.user.value!;
        final memberId = await _memberRepo.addMember(
          familyId: familyId,
          fullName: member.displayName.isEmpty ? 'Admin' : member.displayName,
          avatarUrl: member.avatarUrl,
          gender: Gender.fromString(member.gender),
          generation: 1,
          phone: member.phone,
          email: member.email,
          createdBy: auth.uid,
          linkedUserId: auth.uid,
        );
        await _userRepo.updateMemberAccount(uid: auth.uid, memberId: memberId);
        await NotificationService.instance.subscribeToFamily(familyId);
      }

      await _familyRepo.logActivity(
        familyId: familyId,
        userId: auth.uid,
        action: 'ສ້າງຄອບຄົວ',
        detail: surname,
      );

      UiHelpers.hideLoading();
      UiHelpers.success('ສ້າງຄອບຄົວ "$surname" ສຳເລັດແລ້ວ');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      Get.offAllNamed(Routes.SHELL);
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    surnameController.removeListener(_updateCanSubmit);
    surnameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    provinceController.dispose();
    super.onClose();
  }
}
