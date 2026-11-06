import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/avatar_picker.dart';
import '../../../core/widgets/form_bottom_bar.dart';
import '../component/edit_profile_form.dart';
import '../controllers/edit_profile_controller.dart';

/// ແກ້ໄຂໂປຣໄຟລ໌ຂອງຕົນເອງ
class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.user.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
          physics: const BouncingScrollPhysics(),
          children: [
            Obx(
              () => AvatarPicker(
                onPick: controller.chooseImageSource,
                localImage: controller.pickedImage.value,
                imageUrl: controller.avatarUrl.value,
                name: user?.displayName ?? '',
                size: 112,
                isAdmin: user?.isAdmin ?? false,
              ),
            ),
            SizedBox(height: 12.h),
            EditProfileForm(controller: controller),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => FormBottomBar(
          saveLabel: AppStrings.save,
          isSaving: controller.isSaving.value,
          onSave: controller.save,
        ),
      ),
    );
  }
}
