import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';

/// ຂໍ້ມູນຕິດຕໍ່ ແລະ ຂໍ້ມູນເພີ່ມເຕີມ
class MemberContactSection extends StatelessWidget {
  const MemberContactSection({super.key, required this.controller});

  final MemberFormController controller;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'ຂໍ້ມູນຕິດຕໍ່',
      icon: Icons.contact_phone_outlined,
      children: [
        AppTextField(
          controller: controller.phoneController,
          label: AppStrings.phone,
          hint: '020 xxxx xxxx',
          prefixIcon: Icons.call_outlined,
          isOptional: true,
          keyboardType: TextInputType.phone,
          validator: (v) => Validators.phone(v),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.whatsappController,
          label: AppStrings.whatsapp,
          hint: '020 xxxx xxxx',
          prefixIcon: Icons.chat_outlined,
          isOptional: true,
          keyboardType: TextInputType.phone,
          validator: (v) => Validators.phone(v),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.emailController,
          label: AppStrings.email,
          hint: 'name@email.com',
          prefixIcon: Icons.mail_outline_rounded,
          isOptional: true,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v ?? '').isEmpty ? null : Validators.email(v),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.occupationController,
          label: 'ອາຊີບ',
          hint: 'ຕົວຢ່າງ: ຄູສອນ',
          prefixIcon: Icons.work_outline_rounded,
          isOptional: true,
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.addressController,
          label: 'ທີ່ຢູ່',
          hint: 'ບ້ານ / ເມືອງ / ແຂວງ',
          prefixIcon: Icons.location_on_outlined,
          isOptional: true,
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.noteController,
          label: 'ໝາຍເຫດ',
          hint: 'ຂໍ້ມູນເພີ່ມເຕີມ...',
          prefixIcon: Icons.notes_rounded,
          isOptional: true,
          maxLines: 3,
          maxLength: 300,
        ),
      ],
    );
  }
}
