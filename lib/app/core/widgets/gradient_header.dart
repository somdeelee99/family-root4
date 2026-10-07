import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// ຫົວຂໍ້ແບບ gradient ສຳລັບໜ້າຈໍຕ່າງໆ
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 180,
    this.child,
    this.trailing,
    this.showBack = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final double height;
  final Widget? child;
  final Widget? trailing;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, showBack ? 4.h : 16.h, 20.w, 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBack)
                IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 6.h),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (child != null) ...[SizedBox(height: 18.h), child!],
            ],
          ),
        ),
      ),
    );
  }
}

/// ກາດເສັ້ນໂຄ້ງທີ່ວາງທັບຫົວຂໍ້ gradient ສຳລັບເນື້ອຫາ
class OverlappingSheet extends StatelessWidget {
  const OverlappingSheet({super.key, required this.child, this.overlap = 26});

  final Widget child;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: Offset(0, -overlap.h),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
