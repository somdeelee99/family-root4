import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ປຸ່ມຫຼັກຂອງແອັບ (ມີສະຖານະ loading)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
    this.height,
    this.gradient = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expand;
  final double? height;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppSizes.buttonHeight.h;
    final child = isLoading
        ? SizedBox(
            height: 22.h,
            width: 22.h,
            child: const CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    final disabled = onPressed == null || isLoading;

    Widget base;
    switch (variant) {
      case AppButtonVariant.primary:
        base = gradient && !disabled
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size.fromHeight(buttonHeight),
                  ),
                  child: child,
                ),
              )
            : FilledButton(
                onPressed: disabled ? null : onPressed,
                style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(buttonHeight)),
                child: child,
              );
        break;
      case AppButtonVariant.outline:
        base = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(buttonHeight)),
          child: child,
        );
        break;
      case AppButtonVariant.text:
        base = TextButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;
    }

    return expand
        ? SizedBox(width: double.infinity, height: buttonHeight, child: base)
        : base;
  }
}

enum AppButtonVariant { primary, outline, text }

/// ປຸ່ມເຂົ້າລະບົບຜ່ານໂຊເຊຍ (Google / Facebook / Apple)
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              border:
                  borderColor == null ? null : Border.all(color: borderColor!),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                SizedBox(width: 26.w, height: 26.w, child: icon),
                Expanded(
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: foregroundColor),
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              color: foregroundColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5.sp,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 26.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
