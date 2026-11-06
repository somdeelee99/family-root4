import 'dart:io';

import 'package:family_root/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? phoneNumber;
  String? whatsappNumber;

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
    final max = allMembers
        .map((m) => m.generation)
        .reduce((a, b) => a > b ? a : b);
    return max >= 1 ? max + 1 : 1;
  }

  // ==================== ເລືອກຮູບ ====================

  /// ອະນຸຍາດກ້ອມກ່ອນເປິດກ້ອມຖ່າຍຮູບ (Android 10+ ຕ້ອງຂອບ runtime permission)
  /// ຖ້າບໍ່ໄດ້ຮັບອະນຸຍາດ ຈະບໍ່ເປິດກ້ອມ ເປັນການປ້ອງກັນແອັບຄ້າງ / ປິດ
  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      UiHelpers.error(
        'ບໍ່ໄດ້ຮັບອະນຸຍາດໃຊ້ກ້ອມ ກະລຸນາອະນຸຍາດໃນການຕั้งຄ່າຂອບແອັບ',
      );
    } else {
      UiHelpers.error('ບໍ່ໄດ້ຮັບອະນຸຍາດໃຊ້ກ້ອມ ບໍ່ສາມາດຖ່າຍຮູບໄດ້');
    }
    return false;
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      if (source == ImageSource.camera && !(await _ensureCameraPermission()))
        return;

      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
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
          IOSUiSettings(title: 'ປັບຮູບໂປຣໄຟລ໌', aspectRatioLockEnabled: true),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ຕົວຈັບລາກ (drag handle)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'ປ່ຽນຮູບໂປຣໄຟລ໌',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ເລືອກວິທີທີ່ທ່ານຕ້ອງການ',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),

            _buildOptionTile(
              icon: Icons.photo_library_outlined,
              iconColor: const Color(0xFF6366F1),
              iconBg: const Color(0xFFEEF2FF),
              title: 'ເລືອກຮູບຈາກຄັງຮູບ',
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            const SizedBox(height: 10),

            _buildOptionTile(
              icon: Icons.photo_camera_outlined,
              iconColor: const Color(0xFF10B981),
              iconBg: const Color(0xFFECFDF5),
              title: 'ຖ່າຍຮູບດ້ວຍກ້ອງ',
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.camera);
              },
            ),

            if (avatarUrl.value != null) ...[
              const SizedBox(height: 10),
              _buildOptionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFEF2F2),
                title: 'ລຶບຮູບ',
                onTap: () {
                  Get.back();
                  pickedImage.value = null;
                  avatarUrl.value = null;
                },
              ),
            ],

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ຍົກເລີກ',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ← ສຳຄັນ
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // void chooseImageSource() {
  //   Get.bottomSheet(
  //     Container(
  //       padding: const EdgeInsets.all(18),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.photo_library_outlined),
  //             title: const Text('ເລືອກຮູບ'),
  //             onTap: () {
  //               Get.back();
  //               pickImage();
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_camera_outlined),
  //             title: const Text('ຖ່າຍຮູບ'),
  //             onTap: () {
  //               Get.back();
  //               pickImage(source: ImageSource.camera);
  //             },
  //           ),
  //           if (avatarUrl.value != null)
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.delete_outline_rounded,
  //                 color: Colors.red,
  //               ),
  //               title: const Text(
  //                 'ລຶບຮູບ',
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //               onTap: () {
  //                 Get.back();
  //                 pickedImage.value = null;
  //                 avatarUrl.value = null;
  //               },
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
  List<FamilyMember> get parentCandidates =>
      allMembers
          .where(
            (m) => m.id != memberId.value && m.generation < generation.value,
          )
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
      message: isEdit ? 'ກຳລັງອັບເດດ...' : 'ກຳລັງເພີ່ມສະມາຊິກ...',
    );

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
          deathDate: status.value == MemberStatus.deceased
              ? deathDate.value
              : null,
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
          deathDate: status.value == MemberStatus.deceased
              ? deathDate.value
              : null,
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
      // Get.back;
      Get.offAllNamed(Routes.SHELL);
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
