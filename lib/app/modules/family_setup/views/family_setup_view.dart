import 'package:family_root/app/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/family_setup_controller.dart';

class FamilySetupView extends GetView<FamilySetupController> {
  const FamilySetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.user.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.setupTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.signOut,
            onPressed: () async {
              await AuthService.to.signOut();
              Get.offAllNamed(Routes.AUTH);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 30.h),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ບັດຕ້ອນຮັບ ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
                  boxShadow: AppSizes.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppAvatar(
                          imageUrl: user?.avatarUrl,
                          name: user?.displayName ?? 'A',
                          size: 54,
                          isAdmin: true,
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Admin',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  'ຜູ້ດູແລຄອບຄົວ (Admin)',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      AppStrings.setupSubtitle,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.12, end: 0),
              SizedBox(height: 22.h),

              // ---------- ຟອມ ----------
              Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: AppSizes.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(9.w),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.family_restroom_rounded,
                                size: 18.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'ຂໍ້ມູນຄອບຄົວ',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        AppTextField(
                          controller: controller.surnameController,
                          label: AppStrings.surname,
                          hint: AppStrings.surnameHint,
                          prefixIcon: Icons.badge_outlined,
                          isRequired: true,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              Validators.required(v, field: 'ນາມສະກຸນ'),
                        ),
                        Obx(
                          () => controller.surnameError.value.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    controller.surnameError.value,
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.nameController,
                          label: AppStrings.familyName,
                          hint: 'ຕົວຢ່າງ: ຄອບຄົວວົງສະຫວັນ',
                          prefixIcon: Icons.home_outlined,
                          isOptional: true,
                          textCapitalization: TextCapitalization.words,
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.provinceController,
                          label: AppStrings.province,
                          hint: 'ຕົວຢ່າງ: ນະຄອນຫຼວງວຽງຈັນ',
                          prefixIcon: Icons.location_on_outlined,
                          isOptional: true,
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.descriptionController,
                          label: AppStrings.familyDescription,
                          hint: AppStrings.descriptionHint,
                          prefixIcon: Icons.notes_rounded,
                          isOptional: true,
                          maxLines: 3,
                          maxLength: 300,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 450.ms)
                  .slideY(begin: 0.1, end: 0),
              SizedBox(height: 20.h),

              // ---------- ຄຳແນະນຳ ----------
              _tip(
                'ນາມສະກຸນຈະຖືກໃຊ້ເປັນຮາກຂອງຜັງໄມ້ຄອບຄົວ. ຫາກນາມສະກຸນນີ້ມີຢູ່ແລ້ວ ທ່ານຈະເຂົ້າຮ່ວມຄອບຄົວນັ້ນໂດຍອັດຕະໂນມັດ.',
              ),
              SizedBox(height: 22.h),

              // ---------- ປຸ່ມສ້າງ (ສະແດງເມື່ອມີນາມສະກຸນ) ----------
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: controller.canSubmit
                      ? AppButton(
                          key: const ValueKey('create'),
                          label: AppStrings.createFamily,
                          icon: Icons.check_rounded,
                          gradient: true,
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.createFamily,
                        )
                      : Container(
                          key: const ValueKey('hint'),
                          height: AppSizes.buttonHeight.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd.r,
                            ),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 17.sp,
                                color: AppColors.textHint,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'ກະລຸນາປ້ອນນາມສະກຸນ ເພື່ອສ້າງຄອບຄົວ',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(String text) => Container(
    padding: EdgeInsets.all(13.w),
    decoration: BoxDecoration(
      color: AppColors.info.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_outline_rounded,
          size: 17.sp,
          color: AppColors.info,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}
