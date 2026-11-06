import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// ແຖວຂໍ້ມູນແບບ "ປ້າຍກຳກັບ + ຄ່າ"
///
/// ຮອງຮັບທັງໄອຄອນ ແລະ widget ນຳໜ້າ (ເຊັ່ນ AppAvatar)
/// ເພື່ອໃຊ້ຊ້ຳໃນໜ້າລາຍລະອຽດຕ່າງໆ.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueWidget,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.labelWidth = 96,
    this.showOpenIcon = false,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  }) : assert(icon != null || leading != null);

  final String label;
  final String value;

  /// ໃຊ້ແທນ [value] ເມື່ອຕ້ອງການສະແດງ widget ພິເສດ (ເຊັ່ນ ຮູບ + ຊື່)
  final Widget? valueWidget;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double labelWidth;
  final bool showOpenIcon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ??
              Icon(icon, size: 15.sp, color: AppColors.textHint),
          SizedBox(width: 10.w),
          SizedBox(
            width: labelWidth.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child:
                valueWidget ??
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && showOpenIcon)
            Icon(
              Icons.open_in_new_rounded,
              size: 13.sp,
              color: AppColors.textHint,
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: row,
    );
  }
}
