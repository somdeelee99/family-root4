import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

/// ປຸ່ມຄວບຄຸມການຊູມ (zoom in / out / reset)
class TreeControls extends StatelessWidget {
  const TreeControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    this.onCenter,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final VoidCallback? onCenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.add_rounded, onZoomIn),
        SizedBox(height: 8.h),
        _button(Icons.remove_rounded, onZoomOut),
        SizedBox(height: 8.h),
        _button(Icons.center_focus_strong_rounded, onCenter ?? onReset),
        SizedBox(height: 8.h),
        _button(Icons.zoom_out_map_rounded, onReset),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 2,
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: 38.w,
            height: 38.w,
            child: Icon(icon, size: 19.sp, color: AppColors.primary),
          ),
        ),
      );
}

/// ຄຳອະທິບາຍສັນຍະລັກຂອງຜັງ
class TreeLegend extends StatelessWidget {
  const TreeLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(AppColors.male, 'ຊາຍ'),
          SizedBox(width: 12.w),
          _item(AppColors.female, 'ຍິງ'),
          SizedBox(width: 12.w),
          _item(AppColors.alive, 'ຢູ່'),
          SizedBox(width: 12.w),
          _item(AppColors.deceased, 'ເສຍຊີວິດ'),
        ],
      ),
    );
  }

  Widget _item(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(label,
              style:
                  TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
        ],
      );
}
