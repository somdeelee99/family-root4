import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum InfoBannerTone { info, success, warning, danger }

/// ປ້າຍແຈ້ງເຕືອນ / ຄຳແນະນຳ ສຳລັບໜ້າຕ່າງໆ
///
/// ໃຊ້ທົດແທນ Container ທີ່ຂຽນຊ້ຳໆ ເພື່ອໃຫ້ສີ ແລະ ຮູບແບບຄົງທີ່.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.tone = InfoBannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final InfoBannerTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  Color get _color {
    switch (tone) {
      case InfoBannerTone.info:
        return AppColors.info;
      case InfoBannerTone.success:
        return AppColors.success;
      case InfoBannerTone.warning:
        return AppColors.accent;
      case InfoBannerTone.danger:
        return AppColors.danger;
    }
  }

  Color get _textColor =>
      tone == InfoBannerTone.warning ? const Color(0xFF7A5410) : _color;

  IconData get _defaultIcon {
    switch (tone) {
      case InfoBannerTone.info:
        return Icons.info_outline_rounded;
      case InfoBannerTone.success:
        return Icons.check_circle_outline_rounded;
      case InfoBannerTone.warning:
        return Icons.lightbulb_outline_rounded;
      case InfoBannerTone.danger:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        border: Border.all(color: _color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, size: 17.sp, color: _color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: _textColor,
                height: 1.45,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: _color,
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
