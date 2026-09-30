import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/enums.dart';
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
            // ---------- ຫົວ ----------
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

            // ---------- ສະຖິຕິສ່ວນຕົວ ----------
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                children: [
                  _miniStat(
                    'ສະມາຊິກ',
                    '${controller.totalMembers}',
                    Icons.groups_rounded,
                  ),
                  SizedBox(width: 12.w),
                  _miniStat(
                    'ລຸ້ນ',
                    '${controller.generationCount}',
                    Icons.layers_rounded,
                  ),
                  SizedBox(width: 12.w),
                  _miniStat(
                    'ເຂົ້າໃຊ້ຫຼ້າສຸດ',
                    user?.lastSeenAt == null
                        ? '-'
                        : AppDateUtils.relative(user!.lastSeenAt)
                              .replaceAll('ກ່ອນ', ''),
                    Icons.schedule_rounded,
                  ),
                ],
              ),
            ),

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
                  _menuCard([
                    _menuItem(
                      icon: Icons.edit_outlined,
                      title: controller.isAdmin
                          ? 'ອັບເດດຂໍ້ມູນ ແລະ ຮູບພາບ'
                          : AppStrings.editProfile,
                      subtitle: controller.isAdmin
                          ? 'ປ່ຽນຮູບພາບ ແລະ ຊື່ຂອງທ່ານ'
                          : 'ຊື່, ນາມສະກຸນ, ເບີໂທ, WhatsApp ແລະ ຮູບພາບ',
                      onTap: controller.goToEditProfile,
                    ),
                    _menuItem(
                      icon: Icons.family_restroom_rounded,
                      title: AppStrings.familyInfo,
                      subtitle: controller.family.value?.displayName ?? '-',
                      onTap: controller.goToFamilyInfo,
                    ),
                    // ---------- ການເຊື່ອມຕໍ່ (Admin) ----------
                    if (controller.isAdmin) _loginConnections(),
                  ]),
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
                  _menuCard([
                    Obx(
                      () => _switchItem(
                        icon: Icons.dark_mode_outlined,
                        title: AppStrings.darkMode,
                        subtitle: 'ປ່ຽນໂໝດການສະແດງຜົນ',
                        value: ThemeService.to.isDark.value,
                        onChanged: (_) => controller.toggleTheme(),
                      ),
                    ),
                    Obx(
                      () => _switchItem(
                        icon: Icons.notifications_none_rounded,
                        title: AppStrings.notifications,
                        subtitle: 'ແຈ້ງເຕືອນເມື່ອມີຂໍ້ຄວາມໃໝ່',
                        value: controller.notificationsEnabled.value,
                        onChanged: (_) => controller.toggleNotifications(),
                      ),
                    ),
                    _menuItem(
                      icon: Icons.info_outline_rounded,
                      title: AppStrings.about,
                      subtitle: '${AppStrings.appName} • ${AppStrings.version}',
                      onTap: _showAbout,
                    ),
                  ]),
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

  Widget _miniStat(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17.sp, color: AppColors.primary),
          SizedBox(height: 7.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );

  Widget _menuCard(List<Widget> children) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
      side: const BorderSide(color: AppColors.divider),
    ),
    child: Column(children: children),
  );

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Icon(icon, size: 17.sp, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20.sp,
        color: AppColors.textHint,
      ),
    ),
  );

  Widget _switchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Material(
    type: MaterialType.transparency,
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      secondary: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Icon(icon, size: 17.sp, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
    ),
  );

  /// ສະແດງການເຊື່ອມຕໍ່ການເຂົ້າລະບົບ ຂອງ Admin
  Widget _loginConnections() {
    final user = AuthService.to.user.value;
    final providers = user?.providers ?? const <AuthProviderType>[];
    final all = AuthProviderType.values.where(
      (p) => p != AuthProviderType.password,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 15.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 7.w),
              Text(
                AppStrings.loginConnections,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (final provider in all) ...[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: providers.contains(provider)
                          ? AppColors.primarySoft
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: providers.contains(provider)
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _providerIcon(provider),
                          size: 20.sp,
                          color: providers.contains(provider)
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          provider.label,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: providers.contains(provider)
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider != all.last) SizedBox(width: 8.w),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _providerIcon(AuthProviderType provider) {
    switch (provider) {
      case AuthProviderType.google:
        return Icons.g_mobiledata_rounded;
      case AuthProviderType.facebook:
        return Icons.facebook_rounded;
      case AuthProviderType.apple:
        return Icons.apple_rounded;
      case AuthProviderType.password:
        return Icons.mail_outline_rounded;
    }
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
}
