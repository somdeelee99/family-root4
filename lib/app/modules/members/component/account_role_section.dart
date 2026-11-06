import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/section_card.dart';
import '../../../data/models/enums.dart';
import '../controllers/account_form_controller.dart';
import 'role_option.dart';

/// ເລືອກບົດບາດຂອງບັນຊີ (Member / Admin)
class AccountRoleSection extends StatelessWidget {
  const AccountRoleSection({super.key, required this.controller});

  final AccountFormController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.role,
      icon: Icons.admin_panel_settings_outlined,
      elevated: true,
      children: [
        Obx(
          () => Column(
            children: [
              RoleOption(
                role: UserRole.member,
                icon: Icons.person_rounded,
                title: AppStrings.roleMember,
                description:
                    'ເບິ່ງຂໍ້ມູນ, ແຊັດຫາ ແລະ ແກ້ໄຂໂປຣໄຟລ໌ຂອງຕົນເອງ',
                selected: controller.role.value == UserRole.member,
                onTap: () => controller.setRole(UserRole.member),
              ),
              SizedBox(height: 10.h),
              RoleOption(
                role: UserRole.admin,
                icon: Icons.verified_rounded,
                title: AppStrings.roleAdmin,
                description: 'ຈັດການຜັງ, ສ້າງບັນຊີ ແລະ ຈັດການຂໍ້ມູນທັງໝົດ',
                selected: controller.role.value == UserRole.admin,
                onTap: () => controller.setRole(UserRole.admin),
                isGold: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        const InfoBanner(
          message:
              'Admin ສາມາດກຳນົດ role ຂອງບັນຊີນີ້ໄດ້ທັງ member ແລະ admin',
        ),
      ],
    );
  }
}
