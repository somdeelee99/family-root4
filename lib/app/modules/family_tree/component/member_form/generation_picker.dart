import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';

/// ຊ່ອງເລືອກລຸ້ນ (Generation) ພ້ອມ bottom sheet
class GenerationField extends GetView<MemberFormController> {
  const GenerationField({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormFieldLabel(AppStrings.generation, isRequired: true),
          SizedBox(height: 7.h),
          InkWell(
            onTap: () => _pickGeneration(),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
            child: Container(
              height: AppSizes.inputHeight.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      'ລຸ້ນທີ ${controller.generation.value}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 20.sp,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickGeneration() async {
    final maxGeneration = controller.generation.value > 10
        ? controller.generation.value
        : 10;

    final selected = await Get.bottomSheet<int>(
      Container(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ກຳນົດລຳດັບຊົ່ວຄົນ (Generation)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (var i = 1; i <= maxGeneration; i++)
                  InkWell(
                    onTap: () => Get.back(result: i),
                    borderRadius: BorderRadius.circular(30.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: controller.generation.value == i
                            ? AppColors.primary
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        'ລຸ້ນທີ $i',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: controller.generation.value == i
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );

    if (selected != null) controller.generation.value = selected;
  }
}
