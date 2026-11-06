import 'package:family_root/app/core/constants/app_colors.dart';
import 'package:family_root/app/core/constants/app_sizes.dart';
import 'package:family_root/app/data/models/enums.dart';
import 'package:family_root/app/modules/members/controllers/account_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget RoleOption({
  required UserRole role,
  required IconData icon,
  required String title,
  required String description,
  bool isGold = false,
}) {
  final controller = Get.find<AccountFormController>();

  return Obx(() {
    final selected = controller.role.value == role;
    final color = isGold ? AppColors.accent : AppColors.primary;
    return InkWell(
      onTap: () => controller.setRole(role),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.09)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20.sp,
              color: selected ? color : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  });
}
