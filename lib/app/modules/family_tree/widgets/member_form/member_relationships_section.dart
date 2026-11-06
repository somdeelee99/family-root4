import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../controllers/member_form_controller.dart';
import '../relation_picker.dart';
import 'form_controls.dart';

/// ຄວາມສຳພັນ: ພໍ່, ແມ່, ຄູ່ສົມລົດ, ລູກ, ອ້າຍເອື້ອຍນ້ອງ
class MemberRelationshipsSection extends GetView<MemberFormController> {
  const MemberRelationshipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: AppStrings.relationships,
      icon: Icons.hub_outlined,
      children: [
        Obx(
          () => Column(
            children: [
              RelationSinglePicker(
                label: AppStrings.father,
                icon: Icons.man_rounded,
                members: controller.parentCandidates,
                selectedId: controller.fatherId.value,
                onChanged: (id) => controller.fatherId.value = id,
              ),
              SizedBox(height: 14.h),
              RelationSinglePicker(
                label: AppStrings.mother,
                icon: Icons.woman_rounded,
                members: controller.parentCandidates,
                selectedId: controller.motherId.value,
                onChanged: (id) => controller.motherId.value = id,
              ),
              SizedBox(height: 14.h),
              RelationMultiPicker(
                label: AppStrings.spouse,
                icon: Icons.favorite_rounded,
                members: controller.sameGenerationCandidates,
                selectedIds: controller.spouseIds,
                onToggle: controller.toggleSpouse,
                emptyHint: 'ຕ້ອງມີສະມາຊິກລຸ້ນດຽວກັນກ່ອນ',
              ),
              SizedBox(height: 14.h),
              RelationMultiPicker(
                label: AppStrings.children,
                icon: Icons.child_care_rounded,
                members: controller.childCandidates,
                selectedIds: controller.childIds,
                onToggle: controller.toggleChild,
                emptyHint: 'ຕ້ອງມີສະມາຊິກລຸ້ນຖັດໄປກ່ອນ ຫຼື ປັບລຸ້ນຂອງຄົນນີ້',
              ),
              SizedBox(height: 14.h),
              RelationMultiPicker(
                label: AppStrings.siblings,
                icon: Icons.people_outline_rounded,
                members: controller.sameGenerationCandidates,
                selectedIds: controller.siblingIds,
                onToggle: controller.toggleSibling,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
