import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/phone_field.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/account_form_controller.dart';

/// ຂໍ້ມູນພື້ນຖານຂອງບັນຊີ: ຊື່, ເບີໂທ ແລະ WhatsApp
class AccountInfoSection extends StatelessWidget {
  const AccountInfoSection({super.key, required this.controller});

  final AccountFormController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'ຂໍ້ມູນບັນຊີ',
      icon: Icons.badge_outlined,
      elevated: true,
      children: [
        AppTextField(
          controller: controller.nameController,
          label: AppStrings.fullName,
          hint: 'ຊື່ ແລະ ນາມສະກຸນ',
          prefixIcon: Icons.person_outline_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) => Validators.required(value, field: 'ຊື່'),
        ),
        SizedBox(height: 14.h),
        _fieldLabel(context, 'ເບີໂທລະສັບ'),
        SizedBox(height: 14.h),
        PhoneField(
          textController: controller.phoneController,
          label: AppStrings.phone,
          icon: Icons.call_outlined,
          onChanged: (number) => controller.phoneNumber = number.phoneNumber,
        ),
        SizedBox(height: 14.h),
        _fieldLabel(context, 'WhatsApp'),
        SizedBox(height: 14.h),
        PhoneField(
          textController: controller.whatsappController,
          label: AppStrings.whatsapp,
          icon: Icons.chat_outlined,
          onChanged: (number) => controller.whatsappNumber = number.phoneNumber,
        ),
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
}
