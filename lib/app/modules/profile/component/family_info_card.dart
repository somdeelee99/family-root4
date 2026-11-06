import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/section_card.dart';
import '../../../data/models/family.dart';
import '../controllers/family_info_controller.dart';

/// ກາດຂໍ້ມູນຄອບຄົວ: ຟອມແກ້ໄຂສຳລັບ Admin ຫຼື ລາຍລະອຽດສຳລັບຜູ້ອ່ານ
class FamilyInfoCard extends StatelessWidget {
  const FamilyInfoCard({
    super.key,
    required this.controller,
    required this.family,
  });

  final FamilyInfoController controller;
  final Family family;

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.isEditing.value;

    return SectionCard(
      title: isEditing ? 'ແກ້ໄຂຂໍ້ມູນຄອບຄົວ' : 'ລາຍລະອຽດຄອບຄົວ',
      icon: Icons.home_outlined,
      elevated: true,
      children: isEditing ? _formFields(context) : _infoRows(),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [
      AppTextField(
        controller: controller.surnameController,
        label: AppStrings.surname,
        isRequired: true,
        prefixIcon: Icons.badge_outlined,
        validator: (value) => Validators.required(value, field: 'ນາມສະກຸນ'),
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: controller.nameController,
        label: AppStrings.familyName,
        prefixIcon: Icons.home_outlined,
        isOptional: true,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: controller.provinceController,
        label: AppStrings.province,
        prefixIcon: Icons.location_on_outlined,
        isOptional: true,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: controller.descriptionController,
        label: AppStrings.familyDescription,
        prefixIcon: Icons.notes_rounded,
        isOptional: true,
        maxLines: 4,
        maxLength: 500,
      ),
    ];
  }

  List<Widget> _infoRows() {
    return [
      InfoRow(
        icon: Icons.badge_outlined,
        label: AppStrings.surname,
        value: family.surname,
        labelWidth: 110,
      ),
      InfoRow(
        icon: Icons.home_outlined,
        label: AppStrings.familyName,
        value: family.name.isEmpty ? '-' : family.name,
        labelWidth: 110,
      ),
      InfoRow(
        icon: Icons.location_on_outlined,
        label: AppStrings.province,
        value: family.province?.isEmpty ?? true ? '-' : family.province!,
        labelWidth: 110,
      ),
      InfoRow(
        icon: Icons.notes_rounded,
        label: AppStrings.familyDescription,
        value: family.description.isEmpty ? '-' : family.description,
        labelWidth: 110,
      ),
      InfoRow(
        icon: Icons.calendar_month_outlined,
        label: 'ສ້າງເມື່ອ',
        value: AppDateUtils.format(family.createdAt),
        labelWidth: 110,
      ),
    ];
  }
}
