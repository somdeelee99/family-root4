import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form_card.dart';
import '../widgets/social_login_section.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ---------- ພາກຫົວ ----------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 24.h),
                      Text(
                            AppStrings.login,
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 450.ms)
                          .slideY(begin: 0.2, end: 0),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.loginSubtitle,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Tab Select ----------
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF7A5410),
                  labelStyle: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(
                      // icon: Icon(Icons.share_rounded, size: 18),
                      text: 'ເຂົ້າສຳລັບ ແອັດມິນ',
                    ),
                    Tab(
                      // icon: Icon(Icons.mail_rounded, size: 18),
                      text: 'ເຂົ້າສຳລັບ ສະມາຊຶກ',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ---------- ເນື້ອໃນແຕ່ລະ Tab ----------
            Expanded(child: TabBarView(children: [_socialTab(), _emailTab()])),
          ],
        ),
      ),
    );
  }

  // Tab 1 : ສະແດງແຕ່ Social Login
  Widget _socialTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          const SocialLoginSection()
              .animate()
              .fadeIn(delay: 200.ms, duration: 450.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: 20.h),
          _memberNote(),
          SizedBox(height: 14.h),
          _versionText(),
        ],
      ),
    );
  }

  // Tab 2 : ສະແດງແຕ່ Email / Password
  Widget _emailTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          const LoginFormCard()
              .animate()
              .fadeIn(delay: 200.ms, duration: 450.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: 20.h),
          _memberNote(),
          SizedBox(height: 14.h),
          _versionText(),
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
