import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/account_form_controller.dart';

/// ຂໍ້ມູນເຂົ້າລະບົບ: ອີແມວ ແລະ ລະຫັດຜ່ານ (ສະເພາະຕອນສ້າງໃໝ່)
class AccountCredentialsSection extends StatelessWidget {
  const AccountCredentialsSection({super.key, required this.controller});

  final AccountFormController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'ການເຂົ້າລະບົບ',
      icon: Icons.lock_outline_rounded,
      elevated: true,
      children: [
        AppTextField(
          controller: controller.emailController,
          label: AppStrings.email,
          hint: 'member@email.com',
          prefixIcon: Icons.mail_outline_rounded,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          enabled: !controller.isEdit,
          validator: Validators.email,
        ),
        if (controller.isEdit)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'ບໍ່ສາມາດປ່ຽນອີແມວໄດ້ ເນື່ອງຈາກເປັນບັນຊີເຂົ້າລະບົບ',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
            ),
          ),
        if (!controller.isEdit) ...[
          SizedBox(height: 14.h),
          AppTextField(
            controller: controller.passwordController,
            label: 'ລະຫັດຜ່ານ (ສຳລັບເຂົ້າລະບົບ)',
            hint: 'ຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ',
            isRequired: true,
            validator: Validators.password,
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: controller.generatePassword,
              icon: const Icon(Icons.casino_outlined, size: 16),
              label: Text(
                'ສ້າງລະຫັດແບບສຸ່ມ',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
