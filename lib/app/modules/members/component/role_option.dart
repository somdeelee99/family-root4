import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/enums.dart';

/// ຕົວເລືອກບົດບາດຂອງບັນຊີ (Member / Admin)
///
/// widget ນີ້ບໍ່ຮູ້ຈັກ controller ເລີຍ — ຜູ້ໃຊ້ສົ່ງ [selected] ແລະ [onTap] ເຂົ້າມາ
/// ເພື່ອໃຫ້ທົດສອບ ແລະ ນຳໃຊ້ຄືນໄດ້ງ່າຍ.
class RoleOption extends StatelessWidget {
  const RoleOption({
    super.key,
    required this.role,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.isGold = false,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    final color = isGold ? AppColors.accent : AppColors.primary;

    return InkWell(
      onTap: onTap,
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
  }
}
