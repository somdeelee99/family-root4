import 'package:family_root/app/core/widgets/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/profile_controller.dart';

/// ໜ້າໂປຣໄຟລ໌
/// - Admin: ອັບເດດຮູບພາບ ແລະ ເຫັນການເຊື່ອມຕໍ່ການເຂົ້າລະບົບ (Facebook / Google / Apple)
/// - Member: ແກ້ໄຂ ຮູບພາບ, ຊື່, ນາມສະກຸນ, ເບີໂທ, ເບີ WhatsApp
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.user.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 26.h),
                  child: Column(
                    children: [
                      AppAvatar(
                        imageUrl: user?.avatarUrl,
                        name: user?.displayName ?? '',
                        size: 96,
                        isAdmin: controller.isAdmin,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        user?.displayName ?? AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        user?.email ?? user?.phone ?? '',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    user.isAdmin
                                        ? Icons.verified_rounded
                                        : Icons.person_rounded,
                                    size: 12.sp,
                                    color: user.isAdmin
                                        ? AppColors.accent
                                        : Colors.white,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    user.isAdmin ? 'ADMIN' : 'MEMBER',
                                    style: TextStyle(
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.w800,
                                      color: user.isAdmin
                                          ? AppColors.accent
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Text(
                              controller.family.value?.surname ?? '-',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        controller.roleDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ---------- ບັນຊີ ----------
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'ບັນຊີຂອງຂ້ອຍ',
                    icon: Icons.person_outline_rounded,
                  ),
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        MenuItem(
                          icon: FaIcon(FontAwesomeIcons.edit),
                          title: controller.isAdmin
                              ? 'ອັບເດດຂໍ້ມູນ ແລະ ຮູບພາບ'
                              : AppStrings.editProfile,
                          subtitle: controller.isAdmin
                              ? 'ປ່ຽນຮູບພາບ ແລະ ຊື່ຂອງທ່ານ'
                              : 'ຊື່, ນາມສະກຸນ, ເບີໂທ, WhatsApp ແລະ ຮູບພາບ',
                          onTap: controller.goToEditProfile,
                        ),
                        MenuItem(
                          icon: FaIcon(FontAwesomeIcons.users),
                          title: AppStrings.familyInfo,
                          subtitle: controller.family.value?.displayName ?? '-',
                          onTap: controller.goToFamilyInfo,
                        ),
                        MenuItem(
                          icon: FaIcon(FontAwesomeIcons.trash),
                          title: 'ລຶບບັນຊີ',
                          subtitle: 'ລຶບບັນຊີ ແລະ ຂໍ້ມູນສ່ວນຕົວຂອງທ່ານ',
                          onTap: controller.deleteMyAccount,
                          color: AppColors.danger,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- ຕັ້ງຄ່າ ----------
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: AppStrings.settings,
                    icon: Icons.settings_outlined,
                  ),
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        MenuItem(
                          icon: FaIcon(FontAwesomeIcons.infoCircle),
                          title: AppStrings.about,
                          subtitle:
                              '${AppStrings.appName} • ${AppStrings.version}',
                          onTap: _showAbout,
                        ),
                        MenuItem(
                          icon: FaIcon(FontAwesomeIcons.addressCard),
                          title: 'ຕິດຕໍ່ຫາ',
                          subtitle: 'ທ່ານສາມາດຕິດຕໍ່ ແລະ ລາຍງານບັນຫາໄດ້',
                          onTap: _showContact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- ອອກຈາກລະບົບ ----------
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 30.h),
              child: OutlinedButton.icon(
                onPressed: controller.signOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(AppStrings.signOut),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(52.h),
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout() async {
    final info = await PackageInfo.fromPlatform();
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.park_rounded, color: AppColors.primary, size: 40),
        title: const Text(AppStrings.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Text(
              '${AppStrings.version} ${info.version} (${info.buildNumber})',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'ແອັບຈັດການຜັງໄມ້ຄອບຄົວສຳລັບຄອບຄົວລາວ\nAdmin ຈັດການຂໍ້ມູນ • Member ເຂົ້າຮ່ວມ ແລະ ສື່ສານ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Get.back(),
            child: const Text('ຕົກລົງ'),
          ),
        ],
      ),
    );
  }

  void _showContact() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 36.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'ຕິດຕໍ່ຫາ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'ທ່ານສາມາດຕິດຕໍ່ຫາທິມງານ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Contact cards
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    MenuItem(
                      icon: FaIcon(FontAwesomeIcons.envelope),
                      title: 'Email',
                      subtitle: 'somdeelee99@gmail.com',
                      onTap: controller.emailToSupport,
                    ),
                    SizedBox(height: 10.h),
                    MenuItem(
                      icon: FaIcon(FontAwesomeIcons.phone),
                      title: 'Phone',
                      subtitle: '+856 2078135458',
                      onTap: controller.phoneToSupport,
                    ),
                    SizedBox(height: 10.h),
                    MenuItem(
                      icon: FaIcon(FontAwesomeIcons.whatsapp),
                      title: 'WhatsApp',
                      subtitle: '+856 2078135458',
                      onTap: controller.openWhatsApp,
                    ),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: SizedBox(
                  height: 48.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'ຕົກລົງ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
