import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/edit_profile_controller.dart';

/// ຟອມແກ້ໄຂໂປຣໄຟລ໌: ຊື່, ນາມສະກຸນ, ເບີໂທ, WhatsApp ແລະ ອີແມວ
class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key, required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.user.value;

    return SectionCard(
      title: 'ຂໍ້ມູນສ່ວນຕົວ',
      icon: Icons.person_outline_rounded,
      elevated: true,
      children: [
        AppTextField(
          controller: controller.nameController,
          label: AppStrings.fullName,
          hint: 'ຊື່ຂອງທ່ານ',
          prefixIcon: Icons.person_outline_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) => Validators.required(value, field: 'ຊື່'),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.surnameController,
          label: AppStrings.surname,
          hint: AppStrings.surnameHint,
          prefixIcon: Icons.badge_outlined,
          isOptional: true,
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.phoneController,
          label: AppStrings.phone,
          hint: '020 xxxx xxxx',
          prefixIcon: Icons.call_outlined,
          keyboardType: TextInputType.phone,
          isOptional: true,
          validator: (value) => Validators.phone(value),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.whatsappController,
          label: AppStrings.whatsapp,
          hint: '020 xxxx xxxx',
          prefixIcon: Icons.chat_outlined,
          keyboardType: TextInputType.phone,
          isOptional: true,
          validator: (value) => Validators.phone(value),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          initialValue: user?.email ?? '-',
          label: AppStrings.email,
          prefixIcon: Icons.mail_outline_rounded,
          readOnly: true,
          enabled: false,
          isOptional: true,
        ),
        SizedBox(height: 14.h),
        _RoleNote(isAdmin: user?.isAdmin ?? false),
      ],
    );
  }
}

/// ໝາຍເຫດບົດບາດ: ຜູ້ໃຊ້ບໍ່ສາມາດປ່ຽນບົດບາດຂອງຕົນເອງໄດ້
class _RoleNote extends StatelessWidget {
  const _RoleNote({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppColors.accent : AppColors.primary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Row(
        children: [
          Icon(
            isAdmin ? Icons.verified_rounded : Icons.person_rounded,
            size: 15.sp,
            color: color,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isAdmin
                  ? 'ບົດບາດ: Admin - ຈັດການຄອບຄົວໄດ້ທັງໝົດ'
                  : 'ບົດບາດ: Member - ບໍ່ສາມາດປ່ຽນບົດບາດດ້ວຍຕົນເອງ',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
