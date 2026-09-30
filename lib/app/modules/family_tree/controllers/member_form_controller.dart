import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// ຟອມເພີ່ມ / ແກ້ໄຂ ສະມາຊິກໃນຜັງໄມ້ຄອບຄົວ (Admin ເທົ່ານັ້ນ)
class MemberFormController extends GetxController {
  final MemberRepository _memberRepo = MemberRepository();
  final FamilyRepository _familyRepo = FamilyRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final UserRepository _userRepo = UserRepository();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final RxString memberId = ''.obs;
  final Rx<Gender> gender = Gender.male.obs;
  final Rx<MemberStatus> status = MemberStatus.alive.obs;
  final RxInt generation = 1.obs;
  final Rxn<DateTime> birthDate = Rxn<DateTime>();
  final Rxn<DateTime> deathDate = Rxn<DateTime>();
  final RxnString fatherId = RxnString();
  final RxnString motherId = RxnString();
  final RxList<String> spouseIds = <String>[].obs;
  final RxList<String> childIds = <String>[].obs;
  final RxList<String> siblingIds = <String>[].obs;
  final RxnString linkedUserId = RxnString();
  final RxnString avatarUrl = RxnString();
  final Rx<File?> pickedImage = Rx<File?>(null);

  final RxList<FamilyMember> allMembers = <FamilyMember>[].obs;
  final RxList<AppUser> accounts = <AppUser>[].obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoading = true.obs;

  bool get isEdit => memberId.value.isNotEmpty;
  String get familyId => AuthService.to.familyId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['memberId'] != null) {
      memberId.value = args['memberId'] as String;
    }
    _load();
  }

  Future<void> _load() async {
    if (familyId.isEmpty) {
      isLoading.value = false;
      return;
    }
    allMembers.assignAll(await _memberRepo.fetchAll(familyId));
    _userRepo.usersStream(familyId).listen((list) => accounts.assignAll(list));

    if (isEdit) {
      FamilyMember? member;
      for (final m in allMembers) {
        if (m.id == memberId.value) {
          member = m;
          break;
        }
      }
      member ??= await _memberRepo.fetch(familyId, memberId.value);
      if (member != null) _fill(member);
    } else {
      generation.value = _suggestGeneration();
    }
    isLoading.value = false;
  }

  void _fill(FamilyMember member) {
    nameController.text = member.fullName;
    nicknameController.text = member.nickname ?? '';
    phoneController.text = member.phone ?? '';
    whatsappController.text = member.whatsapp ?? '';
    emailController.text = member.email ?? '';
    occupationController.text = member.occupation ?? '';
    addressController.text = member.address ?? '';
    noteController.text = member.note ?? '';
    gender.value = member.gender;
    status.value = member.status;
    generation.value = member.generation;
    birthDate.value = member.birthDate;
    deathDate.value = member.deathDate;
    fatherId.value = member.fatherId;
    motherId.value = member.motherId;
    spouseIds.assignAll(member.spouseIds);
    childIds.assignAll(member.childIds);
    siblingIds.assignAll(member.siblingIds);
    linkedUserId.value = member.linkedUserId;
    avatarUrl.value = member.avatarUrl;
  }

  /// ແນະນຳລຸ້ນອັດຕະໂນມັດ (ລຸ້ນສູງສຸດ + 1)
  int _suggestGeneration() {
    if (allMembers.isEmpty) return 1;
    final max =
        allMembers.map((m) => m.generation).reduce((a, b) => a > b ? a : b);
    return max >= 1 ? max + 1 : 1;
  }

  // ==================== ເລືອກຮູບ ====================
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ປັບຮູບໂປຣໄຟລ໌',
            toolbarColor: const Color(0xFF1E6F5C),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'ປັບຮູບໂປຣໄຟລ໌',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      pickedImage.value = File(cropped?.path ?? picked.path);
    } catch (e) {
      UiHelpers.error('ເລືອກຮູບບໍ່ສຳເລັດ: $e');
    }
  }

  void chooseImageSource() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ເລືອກຈາກຄັງຮູບ'),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ຖ່າຍຮູບໃໝ່'),
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.camera);
              },
            ),
            if (avatarUrl.value != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title:
                    const Text('ລຶບຮູບ', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  pickedImage.value = null;
                  avatarUrl.value = null;
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==================== ຄວາມສຳພັນ ====================
  void toggleSpouse(String id) => _toggle(spouseIds, id);
  void toggleChild(String id) => _toggle(childIds, id);
  void toggleSibling(String id) => _toggle(siblingIds, id);

  void _toggle(RxList<String> list, String id) {
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
  }

  /// ຜູ້ທີ່ສາມາດເປັນພໍ່ແມ່ (ລຸ້ນກ່ອນໜ້າ)
  List<FamilyMember> get parentCandidates => allMembers
      .where((m) => m.id != memberId.value && m.generation < generation.value)
      .toList()
    ..sort((a, b) => a.generation.compareTo(b.generation));

  /// ຜູ້ທີ່ສາມາດເປັນຄູ່ສົມລົດ / ອ້າຍເອື້ອຍນ້ອງ (ລຸ້ນດຽວກັນ)
  List<FamilyMember> get sameGenerationCandidates => allMembers
      .where((m) => m.id != memberId.value && m.generation == generation.value)
      .toList();

  /// ຜູ້ທີ່ສາມາດເປັນລູກ (ລຸ້ນຖັດໄປ)
  List<FamilyMember> get childCandidates => allMembers
      .where((m) => m.id != memberId.value && m.generation > generation.value)
      .toList();

  // ==================== ບັນທຶກ ====================
  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (AuthService.to.familyId.isEmpty) {
      UiHelpers.error('ບໍ່ພົບຂໍ້ມູນຄອບຄົວ');
      return;
    }
    if (status.value == MemberStatus.deceased && deathDate.value == null) {
      UiHelpers.warning('ກະລຸນາເລືອກວັນເສຍຊີວິດ');
      return;
    }

    if (!isValidChronology()) return;

    isSaving.value = true;
    UiHelpers.loading(
        message: isEdit ? 'ກຳລັງອັບເດດ...' : 'ກຳລັງເພີ່ມສະມາຊິກ...');

    try {
      var finalAvatar = avatarUrl.value;
      if (pickedImage.value != null) {
        finalAvatar = await _storageRepo.uploadMemberPhoto(
          pickedImage.value!,
          familyId,
          isEdit
              ? memberId.value
              : DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      if (isEdit) {
        await _memberRepo.updateMember(
          familyId: familyId,
          memberId: memberId.value,
          fullName: nameController.text.trim(),
          nickname: nicknameController.text.trim(),
          avatarUrl: finalAvatar,
          gender: gender.value,
          status: status.value,
          generation: generation.value,
          birthDate: birthDate.value,
          deathDate:
              status.value == MemberStatus.deceased ? deathDate.value : null,
          phone: phoneController.text.trim(),
          whatsapp: whatsappController.text.trim(),
          email: emailController.text.trim(),
          occupation: occupationController.text.trim(),
          address: addressController.text.trim(),
          note: noteController.text.trim(),
          fatherId: fatherId.value,
          motherId: motherId.value,
          spouseIds: spouseIds,
          childIds: childIds,
          clearFather: fatherId.value == null,
          clearMother: motherId.value == null,
          clearDeathDate: status.value != MemberStatus.deceased,
        );
      } else {
        await _memberRepo.addMember(
          familyId: familyId,
          fullName: nameController.text.trim(),
          nickname: nicknameController.text.trim(),
          avatarUrl: finalAvatar,
          gender: gender.value,
          status: status.value,
          generation: generation.value,
          birthDate: birthDate.value,
          deathDate:
              status.value == MemberStatus.deceased ? deathDate.value : null,
          phone: phoneController.text.trim(),
          whatsapp: whatsappController.text.trim(),
          email: emailController.text.trim(),
          occupation: occupationController.text.trim(),
          address: addressController.text.trim(),
          note: noteController.text.trim(),
          fatherId: fatherId.value,
          motherId: motherId.value,
          spouseIds: spouseIds,
          childIds: childIds,
          createdBy: AuthService.to.uid,
          linkedUserId: linkedUserId.value,
        );
      }

      await _familyRepo.logActivity(
        familyId: familyId,
        userId: AuthService.to.uid,
        action: isEdit ? 'ແກ້ໄຂສະມາຊິກ' : 'ເພີ່ມສະມາຊິກ',
        detail: nameController.text.trim(),
      );

      UiHelpers.hideLoading();
      UiHelpers.success(isEdit ? 'ອັບເດດຂໍ້ມູນສຳເລັດ' : 'ເພີ່ມສະມາຊິກສຳເລັດ');
      Get.back(result: true);
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSaving.value = false;
    }
  }

  /// ກວດສອບຄວາມສົມເຫດສົມຜົນຂອງວັນທີ
  bool isValidChronology() {
    final birth = birthDate.value;
    if (birth == null) return true;
    if (birth.isAfter(DateTime.now())) {
      UiHelpers.warning('ວັນເກີດຕ້ອງບໍ່ຢູ່ໃນອະນາຄົດ');
      return false;
    }
    final death = deathDate.value;
    if (death != null && death.isBefore(birth)) {
      UiHelpers.warning('ວັນເສຍຊີວິດຕ້ອງຫຼັງວັນເກີດ');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    emailController.dispose();
    occupationController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
