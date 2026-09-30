import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// ຟອມສ້າງ / ແກ້ໄຂ ບັນຊີສະມາຊິກ (admin ສ້າງບັນຊີໃຫ້ member)
class AccountFormController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final FamilyRepository _familyRepo = FamilyRepository();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

  final RxString uid = ''.obs;
  final Rx<UserRole> role = UserRole.member.obs;
  final RxnString avatarUrl = RxnString();
  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxBool isSaving = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isActive = true.obs;

  bool get isEdit => uid.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['uid'] != null) {
      uid.value = args['uid'] as String;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final user = await _userRepo.fetch(uid.value);
    if (user == null) return;
    nameController.text = user.displayName;
    emailController.text = user.email ?? '';
    phoneController.text = user.phone ?? '';
    whatsappController.text = user.whatsapp ?? '';
    avatarUrl.value = user.avatarUrl;
    role.value = user.role;
    isActive.value = user.isActive;
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void setRole(UserRole value) => role.value = value;

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
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
  }

  void chooseImageSource() {
    Get.bottomSheet(
      SafeArea(
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
          ],
        ),
      ),
    );
  }

  /// ສ້າງລະຫັດຜ່ານແບບສຸ່ມ (ສະດວກສຳລັບ admin)
  void generatePassword() {
    const chars = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final password = List.generate(10, (i) {
      final index =
          (random.codeUnitAt(i % random.length) + i * 7) % chars.length;
      return chars[index];
    }).join();
    passwordController.text = password;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!isEdit && avatarUrl.value == null && pickedImage.value == null) {
      // ຮູບບໍ່ບັງຄັບ
    }

    final familyId = AuthService.to.familyId;
    if (familyId.isEmpty) {
      UiHelpers.error('ບໍ່ພົບຂໍ້ມູນຄອບຄົວ');
      return;
    }

    isSaving.value = true;
    UiHelpers.loading(
        message: isEdit ? 'ກຳລັງອັບເດດບັນຊີ...' : 'ກຳລັງສ້າງບັນຊີ...');

    try {
      var finalAvatar = avatarUrl.value;
      if (pickedImage.value != null) {
        finalAvatar = await _storageRepo.uploadAvatar(
          pickedImage.value!,
          isEdit ? uid.value : 'tmp-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (isEdit) {
        await _userRepo.updateMemberAccount(
          uid: uid.value,
          displayName: nameController.text.trim(),
          phone: phoneController.text.trim(),
          whatsapp: whatsappController.text.trim(),
          avatarUrl: finalAvatar,
          role: role.value,
          isActive: isActive.value,
        );
        UiHelpers.hideLoading();
        UiHelpers.success('ອັບເດດບັນຊີສຳເລັດ');
      } else {
        final newUid = await _userRepo.createMemberAccount(
          email: emailController.text.trim(),
          password: passwordController.text,
          displayName: nameController.text.trim(),
          role: role.value.value,
          familyId: familyId,
          phone: phoneController.text.trim(),
          whatsapp: whatsappController.text.trim(),
          avatarUrl: finalAvatar,
        );
        await _familyRepo.logActivity(
          familyId: familyId,
          userId: AuthService.to.uid,
          action: 'ສ້າງບັນຊີສະມາຊິກ',
          detail: '${nameController.text.trim()} (${role.value.label})',
        );
        UiHelpers.hideLoading();
        UiHelpers.success('ສ້າງບັນຊີສຳເລັດ • ແຈ້ງອີແມວ ແລະ ລະຫັດໃຫ້ສະມາຊິກ');

        // ສະແດງຂໍ້ມູນບັນຊີທີ່ສ້າງໃໝ່ ເພື່ອສົ່ງຕໍ່
        _showCredentialDialog(
            emailController.text.trim(), passwordController.text, newUid);
        return;
      }
      Get.back(result: true);
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSaving.value = false;
    }
  }

  void _showCredentialDialog(String email, String password, String newUid) {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.check_circle_rounded,
            color: Color(0xFF22A06B), size: 40),
        title: const Text('ສ້າງບັນຊີສຳເລັດ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ກະລຸນາສົ່ງຂໍ້ມູນນີ້ໃຫ້ສະມາຊິກ ເພື່ອເຂົ້າລະບົບ:',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            _credentialRow('ອີແມວ', email),
            const SizedBox(height: 6),
            _credentialRow('ລະຫັດຜ່ານ', password),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: const Text('ຕົກລົງ'),
          ),
        ],
      ),
    );
  }

  Widget _credentialRow(String label, String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF6B7C77))),
            ),
            Expanded(
              child: SelectableText(
                value,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    super.onClose();
  }
}
