import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/avatar_picker.dart';
import '../../../core/widgets/form_bottom_bar.dart';
import '../component/account_active_switch.dart';
import '../component/account_credentials_section.dart';
import '../component/account_info_section.dart';
import '../component/account_role_section.dart';
import '../controllers/account_form_controller.dart';

/// ຟອມສ້າງ / ແກ້ໄຂ ບັນຊີສະມາຊິກ
class AccountFormView extends GetView<AccountFormController> {
  const AccountFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          controller.isEdit ? AppStrings.editAccount : AppStrings.addAccount,
        ),
      ),
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
                name: controller.nameController.text.isEmpty
                    ? 'ສ'
                    : controller.nameController.text,
                size: 110,
              ),
            ),
            SizedBox(height: 12.h),
            AccountInfoSection(controller: controller),
            SizedBox(height: 14.h),
            AccountCredentialsSection(controller: controller),
            SizedBox(height: 14.h),
            AccountRoleSection(controller: controller),
            if (controller.isEdit) ...[
              SizedBox(height: 14.h),
              AccountActiveSwitch(controller: controller),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => FormBottomBar(
          saveLabel: controller.isEdit ? AppStrings.update : 'ສ້າງບັນຊີ',
          saveIcon: controller.isEdit
              ? Icons.check_rounded
              : Icons.person_add_alt_1_rounded,
          isSaving: controller.isSaving.value,
          onSave: controller.save,
        ),
      ),
    );
  }
}
