import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/menu_item.dart';
import '../component/about_app_dialog.dart';
import '../component/contact_support_dialog.dart';
import '../component/profile_header.dart';
import '../component/profile_menu_group.dart';
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
            ProfileHeader(
              user: user,
              familySurname: controller.family.value?.surname ?? '',
              roleDescription: controller.roleDescription,
            ).animate().fadeIn(duration: 400.ms),

            ProfileMenuGroup(
              title: 'ບັນຊີຂອງຂ້ອຍ',
              icon: Icons.person_outline_rounded,
              children: [
                MenuItem(
                  icon: FaIcon(FontAwesomeIcons.penToSquare),
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

            ProfileMenuGroup(
              title: AppStrings.settings,
              icon: Icons.settings_outlined,
              children: [
                MenuItem(
                  icon: FaIcon(FontAwesomeIcons.circleInfo),
                  title: AppStrings.about,
                  subtitle: '${AppStrings.appName} • ${AppStrings.version}',
                  onTap: showAboutAppDialog,
                ),
                MenuItem(
                  icon: FaIcon(FontAwesomeIcons.addressCard),
                  title: 'ຕິດຕໍ່ຫາ',
                  subtitle: 'ທ່ານສາມາດຕິດຕໍ່ ແລະ ລາຍງານບັນຫາໄດ້',
                  onTap: _showContact,
                ),
              ],
            ),

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

  void _showContact() {
    ContactSupportDialog.show(
      email: ProfileController.email,
      phone: ProfileController.phoneNumber,
      onEmail: controller.emailToSupport,
      onPhone: controller.phoneToSupport,
      onWhatsApp: controller.openWhatsApp,
    );
  }
}
