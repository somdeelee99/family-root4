import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/storage_repository.dart';

/// ແກ້ໄຂໂປຣໄຟລ໌ຂອງຕົນເອງ
/// - Member: ຮູບພາບ, ຊື່, ນາມສະກຸນ, ເບີໂທ, ເບີ WhatsApp
/// - Admin: ຮູບພາບ ແລະ ຊື່ (ພ້ອມເຫັນການເຊື່ອມຕໍ່ໃນໜ້າໂປຣໄຟລ໌)
class EditProfileController extends GetxController {
  final StorageRepository _storageRepo = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

  final RxnString avatarUrl = RxnString();
  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxBool isSaving = false.obs;

  bool get isAdmin => AuthService.to.isAdmin;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.to.user.value;
    if (user != null) {
      nameController.text = user.displayName;
      surnameController.text = user.surname ?? '';
      phoneController.text = user.phone ?? '';
      whatsappController.text = user.whatsapp ?? '';
      avatarUrl.value = user.avatarUrl;
    }
  }

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

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;
    UiHelpers.loading(message: 'ກຳລັງບັນທຶກ...');
    try {
      var finalAvatar = avatarUrl.value;
      if (pickedImage.value != null) {
        finalAvatar = await _storageRepo.uploadAvatar(
            pickedImage.value!, AuthService.to.uid);
      }

      final ok = await AuthService.to.updateMyProfile(
        displayName: nameController.text.trim(),
        surname: surnameController.text.trim(),
        phone: phoneController.text.trim(),
        whatsapp: whatsappController.text.trim(),
        avatarUrl: finalAvatar,
      );

      UiHelpers.hideLoading();
      if (ok) {
        UiHelpers.success('ອັບເດດໂປຣໄຟລ໌ສຳເລັດ');
        Get.back();
      } else {
        UiHelpers.error(AuthService.to.errorMessage.value);
      }
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    super.onClose();
  }
}
