import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/enums.dart';
import '../controllers/auth_controller.dart';

class SocialLoginSection extends GetView<AuthController> {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _badge(Icons.shield_moon_rounded, AppColors.accent, 'Admin'),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'ເຂົ້າລະບົບສຳລັບຜູ້ດູແລຄອບຄົວ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ✅ Google - มี Obx ของตัวเอง
          Obx(
            () => SocialLoginButton(
              label: AppStrings.continueWithGoogle,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3C4043),
              borderColor: AppColors.divider,
              icon: CustomPaint(
                size: Size(24.w, 24.w),
                painter: _GoogleLogoPainter(),
              ),
              isLoading: controller.isGoogleLoading, // ✅ แก้จาก isBusy
              onPressed: controller.isBusy
                  ? null
                  : () => controller.signInWithgoogle(AuthProviderType.google),
            ),
          ),
          SizedBox(height: 10.h),

          // ✅ Facebook - มี Obx ของตัวเอง
          Obx(
            () => SocialLoginButton(
              label: AppStrings.continueWithFacebook,
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              icon: Icon(
                Icons.facebook_rounded,
                size: 26.sp,
                color: Colors.white,
              ),
              isLoading: controller.isFacebookLoading, // ✅ แก้จาก isBusy
              onPressed: controller.isBusy
                  ? null
                  : controller.signInWithFacebook,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, Color color, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(30.r),
    ),
    child: Row(
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.39;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.21
      ..strokeCap = StrokeCap.butt;
    const segments = [
      (2.7, 4.5, Color(0xFFEA4335)),
      (4.5, 5.6, Color(0xFF4285F4)),
      (5.6, 7.0, Color(0xFF34A853)),
      (7.0, 9.0, Color(0xFFFBBC05)),
    ];
    for (final seg in segments) {
      paint.color = seg.$3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        seg.$1,
        seg.$2 - seg.$1,
        false,
        paint,
      );
    }
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.46,
        size.width * 0.48,
        size.height * 0.12,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
