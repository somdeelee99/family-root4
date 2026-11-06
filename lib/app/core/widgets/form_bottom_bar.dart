import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// ແຖບປຸ່ມດ້ານລຸ່ມຂອງຟອມ (ຍົກເລີກ / ບັນທຶກ)
///
/// ຮອງຮັບສະຖານະກຳລັງບັນທຶກ ແລະ ການສະແດງປຸ່ມຍົກເລີກແບບເລືອກໄດ້.
class FormBottomBar extends StatelessWidget {
  const FormBottomBar({
    super.key,
    required this.saveLabel,
    required this.onSave,
    this.cancelLabel,
    this.onCancel,
    this.isSaving = false,
    this.isDisabled = false,
    this.saveIcon = Icons.check_rounded,
    this.cancelIcon,
  });

  final String saveLabel;
  final VoidCallback onSave;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final bool isSaving;
  final bool isDisabled;
  final IconData saveIcon;
  final IconData? cancelIcon;

  @override
  Widget build(BuildContext context) {
    final showCancel = onCancel != null;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showCancel) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(52.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cancelIcon != null) ...[
                        Icon(cancelIcon, size: 18.sp),
                        SizedBox(width: 6.w),
                      ],
                      Text(cancelLabel ?? 'ຍົກເລີກ'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              flex: showCancel ? 2 : 1,
              child: FilledButton.icon(
                onPressed: isSaving || isDisabled ? null : onSave,
                icon: isSaving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(saveIcon, size: 20.sp),
                label: Text(saveLabel),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(showCancel ? 52.h : 54.h),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
