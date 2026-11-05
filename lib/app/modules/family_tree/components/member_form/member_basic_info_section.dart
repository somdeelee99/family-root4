import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/enums.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';
import 'generation_picker.dart';

/// ຂໍ້ມູນພື້ນຖານ: ຊື່, ຊື່ຫຼິ້ນ, ເພດ, ວັນເກີດ, ລຸ້ນ
class MemberBasicInfoSection extends StatelessWidget {
  const MemberBasicInfoSection({super.key, required this.controller});

  final MemberFormController controller;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'ຂໍ້ມູນພື້ນຖານ',
      icon: Icons.person_outline_rounded,
      children: [
        AppTextField(
          controller: controller.nameController,
          label: 'ຊື່ ແລະ ນາມສະກຸນ',
          hint: 'ຕົວຢ່າງ: ສົມພອນ ວົງສະຫວັນ',
          prefixIcon: Icons.person_outline_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, field: 'ຊື່ ແລະ ນາມສະກຸນ'),
        ),
        SizedBox(height: 14.h),
        AppTextField(
          controller: controller.nicknameController,
          label: 'ຊື່ຫຼິ້ນ',
          hint: 'ຕົວຢ່າງ: ພອນ',
          prefixIcon: Icons.emoji_emotions_outlined,
          isOptional: true,
        ),
        SizedBox(height: 16.h),
        const FormFieldLabel('ເພດ', isRequired: true),
        SizedBox(height: 8.h),
        Obx(
          () => FormSegmented<Gender>(
            values: const [Gender.male, Gender.female, Gender.other],
            selected: controller.gender.value,
            labelOf: (g) => g.label,
            iconOf: (g) => g == Gender.female
                ? Icons.female_rounded
                : g == Gender.male
                ? Icons.male_rounded
                : Icons.transgender_rounded,
            onChanged: (value) => controller.gender.value = value,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => AppDateField(
            label: 'ວັນເກີດ',
            value: controller.birthDate.value,
            isOptional: true,
            onTap: () => _pickBirthDate(context),
          ),
        ),
        SizedBox(height: 16.h),
        GenerationField(controller: controller),
        SizedBox(height: 8.h),
        Text(
          'ແນະນຳ: ລຸ້ນຈະຖືກຄຳນວນອັດຕະໂນມັດ ເມື່ອກຳນົດພໍ່ແມ່ (ລູກ = ລຸ້ນພໍ່ແມ່ + 1)',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
        ),
      ],
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final picked = await showFormDatePicker(
      context: context,
      initial: controller.birthDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) controller.birthDate.value = picked;
  }
}
