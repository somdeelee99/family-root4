import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/family_info_controller.dart';

/// ຂໍ້ມູນຄອບຄົວ (ນາມສະກຸນ ແລະ ລາຍລະອຽດ)
class FamilyInfoView extends GetView<FamilyInfoController> {
  const FamilyInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.familyInfo),
        actions: [
          Obx(
            () => controller.isAdmin
                ? controller.isEditing.value
                      ? Row(
                          children: [
                            IconButton(
                              onPressed: controller.cancelEditing,
                              icon: const Icon(Icons.close_rounded),
                            ),
                            IconButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : controller.save,
                              icon: const Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                        )
                      : IconButton(
                          onPressed: controller.startEditing,
                          icon: const Icon(Icons.edit_outlined),
                        )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        final family = controller.family.value;
        if (family == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              // ---------- ປົກຄອບຄົວ ----------
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
                  image: _coverDecoration(family.coverUrl),
                  boxShadow: AppSizes.cardShadow,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.park_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 34.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            family.displayName,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'ນາມສະກຸນ ${family.surname}',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.isEditing.value)
                      Positioned(
                        right: 12.w,
                        bottom: 12.h,
                        child: InkWell(
                          onTap: controller.pickCover,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 11.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'ປ່ຽນຮູບປົກ',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
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
              SizedBox(height: 18.h),

              // ---------- ສະຖິຕິ ----------
              Row(
                children: [
                  _stat(
                    'ສະມາຊິກ',
                    '${controller.totalMembers}',
                    AppColors.primary,
                  ),
                  SizedBox(width: 10.w),
                  _stat(
                    'ລຸ້ນ',
                    '${controller.generationCount}',
                    AppColors.info,
                  ),
                  SizedBox(width: 10.w),
                  _stat(
                    'ຊາຍ/ຍິງ',
                    '${controller.maleCount}/${controller.femaleCount}',
                    AppColors.accent,
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // ---------- ຟອມ / ລາຍລະອຽດ ----------
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Obx(
                  () => controller.isEditing.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: controller.surnameController,
                              label: AppStrings.surname,
                              isRequired: true,
                              prefixIcon: Icons.badge_outlined,
                              validator: (v) =>
                                  Validators.required(v, field: 'ນາມສະກຸນ'),
                            ),
                            SizedBox(height: 14.h),
                            AppTextField(
                              controller: controller.nameController,
                              label: AppStrings.familyName,
                              prefixIcon: Icons.home_outlined,
                              isOptional: true,
                            ),
                            SizedBox(height: 14.h),
                            AppTextField(
                              controller: controller.provinceController,
                              label: AppStrings.province,
                              prefixIcon: Icons.location_on_outlined,
                              isOptional: true,
                            ),
                            SizedBox(height: 14.h),
                            AppTextField(
                              controller: controller.descriptionController,
                              label: AppStrings.familyDescription,
                              prefixIcon: Icons.notes_rounded,
                              isOptional: true,
                              maxLines: 4,
                              maxLength: 500,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(
                              Icons.badge_outlined,
                              AppStrings.surname,
                              family.surname,
                            ),
                            _infoRow(
                              Icons.home_outlined,
                              AppStrings.familyName,
                              family.name.isEmpty ? '-' : family.name,
                            ),
                            _infoRow(
                              Icons.location_on_outlined,
                              AppStrings.province,
                              family.province?.isEmpty ?? true
                                  ? '-'
                                  : family.province!,
                            ),
                            _infoRow(
                              Icons.notes_rounded,
                              AppStrings.familyDescription,
                              family.description.isEmpty
                                  ? '-'
                                  : family.description,
                            ),
                            _infoRow(
                              Icons.calendar_month_outlined,
                              'ສ້າງເມື່ອ',
                              family.createdAt == null
                                  ? '-'
                                  : '${family.createdAt!.day}/${family.createdAt!.month}/${family.createdAt!.year}',
                            ),
                          ],
                        ),
                ),
              ),
              if (!controller.isAdmin) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(13.w),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: Color(0xFF9A6A11),
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: Text(
                          'Member ສາມາດເບິ່ງຂໍ້ມູນຄອບຄົວໄດ້ຢ່າງດຽວ (ການແກ້ໄຂເປັນສິດຂອງ Admin)',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF7A5410),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  DecorationImage? _coverDecoration(String? coverUrl) {
    if (controller.pickedCover.value != null) {
      return DecorationImage(
        image: FileImage(controller.pickedCover.value!),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.35),
          BlendMode.darken,
        ),
      );
    }
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return DecorationImage(
        image: CachedNetworkImageProvider(coverUrl),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.4),
          BlendMode.darken,
        ),
      );
    }
    return null;
  }

  Widget _stat(String label, String value, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 7.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.textHint),
        SizedBox(width: 10.w),
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5.sp, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
