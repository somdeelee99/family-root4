import 'package:family_root/app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/enums.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form_card.dart';
import '../widgets/social_login_section.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ---------- ພາກຫົວ ----------
          Container(
            // height: 330.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.park_rounded,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Text(
                          AppStrings.login,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.2, end: 0),
                    SizedBox(height: 10.h),
                    Text(
                      AppStrings.loginSubtitle,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 450.ms),
                  ],
                ),
              ),
            ),
          ),

          // ---------- ເນື້ອຫາ ----------
          Positioned.fill(
            top: 250.h,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 34.h),
              child: Column(
                children: [
                  const SocialLoginSection()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 450.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 14.h),
                  const LoginFormCard()
                      .animate()
                      .fadeIn(delay: 320.ms, duration: 450.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 18.h),
                  _memberNote(),
                  SizedBox(height: 14.h),
                  _versionText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberNote() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17.sp,
            color: const Color(0xFF9A6A11),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              AppStrings.memberOnlyNote,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF7A5410),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _versionText() {
    return Text(
      '${AppStrings.appName} • ${AppStrings.version} 1.0.0',
      style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
    );
  }
}

/// ປຸ່ມເຂົ້າລະບົບທີ່ສະແດງຜົນການເຮັດວຽກ
class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Obx(
      () => AppButton(
        label: label,
        onPressed: controller.isBusy ? null : onPressed,
        isLoading: controller.isBusy,
        gradient: true,
      ),
    );
  }
}

/// ຕົວຊ່ວຍສຳລັບໂຊເຊຍ
class ProviderIcon extends StatelessWidget {
  const ProviderIcon({super.key, required this.provider});

  final AuthProviderType provider;

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case AuthProviderType.google:
        return CustomPaint(size: Size(24.w, 24.w), painter: _GooglePainter());
      case AuthProviderType.facebook:
        return Icon(Icons.facebook_rounded, size: 26.sp, color: Colors.white);
      case AuthProviderType.apple:
        return Icon(Icons.apple_rounded, size: 26.sp, color: Colors.white);
      case AuthProviderType.password:
        return Icon(
          Icons.mail_outline_rounded,
          size: 24.sp,
          color: AppColors.primary,
        );
    }
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;

    const segments = [
      (0.0, 1.05, Color(0xFFEA4335)),
      (1.05, 2.1, Color(0xFF4285F4)),
      (2.1, 3.15, Color(0xFF34A853)),
      (3.15, 4.2, Color(0xFFFBBC05)),
    ];
    for (final seg in segments) {
      paint.color = seg.$3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.78),
        seg.$1,
        seg.$2 - seg.$1,
        false,
        paint,
      );
    }
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.44,
        size.width * 0.46,
        size.height * 0.13,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
