import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            // ວົງມົນຕົກແຕ່ງພື້ນຫຼັງ
            Positioned(
              top: -70.h,
              right: -50.w,
              child: _circle(210, Colors.white.withValues(alpha: 0.06)),
            ),
            Positioned(
              bottom: -90.h,
              left: -60.w,
              child: _circle(260, Colors.white.withValues(alpha: 0.05)),
            ),
            Column(
              children: [
                const Spacer(flex: 3),
                Container(
                      padding: EdgeInsets.all(26.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      // child: Icon(
                      //   Icons.park_rounded,
                      //   size: 60.sp,
                      //   color: Colors.white,
                      // ),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 60.w,
                        height: 60.w,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      curve: Curves.easeOutBack,
                      duration: 700.ms,
                    ),
                SizedBox(height: 26.h),
                Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.25, end: 0),
                SizedBox(height: 10.h),
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ).animate().fadeIn(delay: 420.ms, duration: 500.ms),
                const Spacer(flex: 3),
                Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: LinearProgressIndicator(
                        value: controller.progress.value,
                        minHeight: 5.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  AppStrings.loading,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 46.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size.w,
    height: size.w,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
