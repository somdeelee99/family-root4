import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/enums.dart';
import '../controllers/edit_profile_controller.dart';

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
            Center(
              child: Obx(
                () => GestureDetector(
                  onTap: controller.chooseImageSource,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (controller.pickedImage.value != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.file(
                            controller.pickedImage.value! as File,
                            width: 112.w,
                            height: 112.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        AppAvatar(
                          imageUrl: controller.avatarUrl.value,
                          name: user?.displayName ?? '',
                          size: 112,
                          borderRadius: BorderRadius.circular(32.r),
                          isAdmin: user?.isAdmin ?? false,
                        ),
                      Positioned(
                        right: -3.w,
                        bottom: -3.h,
                        child: Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded, size: 15.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Center(
              child: TextButton(
                onPressed: controller.chooseImageSource,
                child: const Text(AppStrings.changePhoto),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppSizes.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: controller.nameController,
                    label: AppStrings.fullName,
                    hint: 'ຊື່ ແລະ ນາມສະກຸນ',
                    prefixIcon: Icons.person_outline_rounded,
                    isRequired: true,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, field: 'ຊື່'),
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    controller: controller.surnameController,
                    label: AppStrings.surname,
                    hint: 'ຕົວຢ່າງ: ວົງສະຫວັນ',
                    prefixIcon: Icons.badge_outlined,
                    isOptional: true,
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    controller: controller.phoneController,
                    label: AppStrings.phone,
                    hint: '020 xxxx xxxx',
                    prefixIcon: Icons.call_outlined,
                    keyboardType: TextInputType.phone,
                    isOptional: true,
                    validator: (v) => Validators.phone(v),
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    controller: controller.whatsappController,
                    label: AppStrings.whatsapp,
                    hint: '020 xxxx xxxx',
                    prefixIcon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                    isOptional: true,
                    validator: (v) => Validators.phone(v),
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    controller: TextEditingController(text: user?.email ?? '-'),
                    label: AppStrings.email,
                    prefixIcon: Icons.mail_outline_rounded,
                    readOnly: true,
                    enabled: false,
                    isOptional: true,
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          user?.isAdmin ?? false ? Icons.verified_rounded : Icons.person_rounded,
                          size: 15.sp,
                          color: user?.isAdmin ?? false ? AppColors.accent : AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            user?.isAdmin ?? false
                                ? 'ບົດບາດ: Admin - ຈັດການຄອບຄົວໄດ້ທັງໝົດ'
                                : 'ບົດບາດ: Member - ບໍ່ສາມາດປ່ຽນບົດບາດດ້ວຍຕົນເອງ',
                            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: controller.isSaving.value ? null : controller.save,
              icon: controller.isSaving.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 20),
              label: const Text(AppStrings.save),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(54.h),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
