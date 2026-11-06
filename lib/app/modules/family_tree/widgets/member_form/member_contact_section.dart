import 'package:family_root/app/modules/family_tree/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';

/// ຂໍ້ມູນຕິດຕໍ່ ແລະ ຂໍ້ມູນເພີ່ມເຕີມ
class MemberContactSection extends GetView<MemberFormController> {
  const MemberContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'ຂໍ້ມູນຕິດຕໍ່',
      icon: Icons.contact_phone_outlined,
      children: [
        Text('ເບີໂທລະສັບ', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: 14.h),
        PhoneField(
          textController: controller.phoneController,
          label: AppStrings.phone,
          icon: Icons.call_outlined,
          onChanged: (number) => controller.phoneNumber = number.phoneNumber,
        ),
        SizedBox(height: 14.h),

        Text('Whatsapp', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: 14.h),
        PhoneField(
          textController: controller.whatsappController,
          label: AppStrings.whatsapp,
          icon: Icons.chat_outlined,
          onChanged: (number) => controller.whatsappNumber = number.phoneNumber,
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
