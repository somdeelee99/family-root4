import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// ຫົວໜ້າໜ້າຈໍສີຂາວ ທີ່ໃຊ້ຊ້ຳໃນຫຼາຍໜ້າ
/// (ສະມາຊິກ, ສົນທະນາ, ຜັງໄມ້ຄອບຄົວ)
///
/// ປະກອບດ້ວຍ ໄອຄອນ, ຫົວຂໍ້, ຄຳອະທິບາຍ, ປຸ່ມທາງຂວາ
/// ແລະ ພາກລຸ່ມ (ເຊັ່ນ ຊ່ອງຄົ້ນຫາ) ແບບຍືດຫຍຸ່ນ.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.padding,
    this.elevated = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIcon(icon: icon),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (bottom != null) ...[SizedBox(height: 12.h), bottom!],
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, size: 18.sp, color: Colors.white),
    );
  }
}
