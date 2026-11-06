import 'package:family_root/app/core/constants/app_colors.dart';
import 'package:family_root/app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget CardWidget({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Container(
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
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 16.sp, color: AppColors.primary),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    ),
  );
}
