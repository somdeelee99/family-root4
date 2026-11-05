import 'package:family_root/app/core/constants/app_colors.dart';
import 'package:family_root/app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget MenuItem({
  required Widget icon,
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
      child: IconTheme(
        data: IconThemeData(size: 17.sp, color: color),
        child: icon,
      ),
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
    trailing: FaIcon(
      FontAwesomeIcons.chevronRight,
      size: 16.sp,
      color: AppColors.textHint,
    ),
  ),
);
