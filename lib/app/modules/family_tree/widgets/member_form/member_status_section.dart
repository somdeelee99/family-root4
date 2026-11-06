import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/enums.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';

/// ສະຖານະຂອງສະມາຊິກ (ຢູ່ / ເສຍຊີວິດ / ຢ່າຮ້າງ)
class MemberStatusSection extends GetView<MemberFormController> {
  const MemberStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'ສະຖານະ',
      icon: Icons.favorite_border_rounded,
      children: [
        Obx(
          () => FormSegmented<MemberStatus>(
            values: MemberStatus.values,
            selected: controller.status.value,
            labelOf: (s) => s.shortLabel,
            iconOf: (s) => s == MemberStatus.alive
                ? Icons.favorite_rounded
                : s == MemberStatus.deceased
                ? Icons.spa_rounded
                : Icons.heart_broken_rounded,
            onChanged: (value) => controller.status.value = value,
          ),
        ),
        Obx(
          () => controller.status.value != MemberStatus.deceased
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: AppDateField(
                    label: 'ວັນເສຍຊີວິດ',
                    value: controller.deathDate.value,
                    isRequired: true,
                    icon: Icons.spa_rounded,
                    onTap: () => _pickDeathDate(context),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _pickDeathDate(BuildContext context) async {
    final picked = await showFormDatePicker(
      context: context,
      initial: controller.deathDate.value,
    );
    if (picked != null) controller.deathDate.value = picked;
  }
}
