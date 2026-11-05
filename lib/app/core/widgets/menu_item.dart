import 'package:family_root/app/core/constants/app_colors.dart';
import 'package:family_root/app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget MenuItem({
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
  Color color = AppColors.primary,
}) => Material(
  type: MaterialType.transparency,
  child: ListTile(
    onTap: onTap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
    leading: Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Icon(icon, size: 17.sp, color: color),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle,
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
          ),
    trailing: Icon(
      Icons.chevron_right_rounded,
      size: 20.sp,
      color: AppColors.textHint,
    ),
  ),
);
