import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/section_card.dart';
import '../../../data/models/family_member.dart';
import '../../family_tree/component/member_detail_sheet.dart';
import '../controllers/member_detail_controller.dart';

/// ຂໍ້ມູນບຸກຄົນ ແລະ ຄວາມສຳພັນ ສຳລັບໜ້າລາຍລະອຽດສະມາຊິກ
class PersonInfoSection extends StatelessWidget {
  const PersonInfoSection({
    super.key,
    required this.person,
    required this.controller,
  });

  final FamilyMember person;
  final MemberDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: AppStrings.personInfo,
          icon: Icons.badge_outlined,
          children: [
            InfoRow(
              icon: Icons.cake_outlined,
              label: 'ວັນເກີດ',
              value: person.birthDate == null
                  ? '-'
                  : AppDateUtils.format(person.birthDate),
            ),
            if (person.birthDate != null)
              InfoRow(
                icon: Icons.timelapse_rounded,
                label: 'ອາຍຸ',
                value: AppDateUtils.ageLabel(
                  person.birthDate,
                  deathDate: person.deathDate,
                ),
              ),
            if (person.deathDate != null)
              InfoRow(
                icon: Icons.spa_rounded,
                label: 'ວັນເສຍຊີວິດ',
                value: AppDateUtils.format(person.deathDate),
              ),
            if ((person.occupation ?? '').isNotEmpty)
              InfoRow(
                icon: Icons.work_outline_rounded,
                label: 'ອາຊີບ',
                value: person.occupation!,
              ),
            if ((person.address ?? '').isNotEmpty)
              InfoRow(
                icon: Icons.location_on_outlined,
                label: 'ທີ່ຢູ່',
                value: person.address!,
              ),
            if ((person.note ?? '').isNotEmpty)
              InfoRow(
                icon: Icons.notes_rounded,
                label: 'ໝາຍເຫດ',
                value: person.note!,
              ),
          ],
        ),
        if (_hasRelations) ...[
          SizedBox(height: 14.h),
          SectionCard(
            title: AppStrings.relationships,
            icon: Icons.hub_outlined,
            children: [
              if (controller.father != null)
                _personRow(
                  Icons.man_rounded,
                  AppStrings.father,
                  controller.father!,
                ),
              if (controller.mother != null)
                _personRow(
                  Icons.woman_rounded,
                  AppStrings.mother,
                  controller.mother!,
                ),
              for (final spouse in controller.spouses)
                _personRow(Icons.favorite_rounded, AppStrings.spouse, spouse),
              for (final child in controller.children)
                _personRow(
                  Icons.child_care_rounded,
                  AppStrings.children,
                  child,
                ),
              for (final sibling in controller.siblings)
                _personRow(
                  Icons.people_outline_rounded,
                  AppStrings.siblings,
                  sibling,
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _hasRelations =>
      controller.father != null ||
      controller.mother != null ||
      controller.spouses.isNotEmpty ||
      controller.children.isNotEmpty ||
      controller.siblings.isNotEmpty;

  Widget _personRow(IconData icon, String label, FamilyMember person) {
    return InfoRow(
      icon: icon,
      label: label,
      onTap: () => showMemberDetailSheet(
        person,
        allMembers: controller.allMembers,
      ),
      valueWidget: Row(
        children: [
          AppAvatar(
            imageUrl: person.avatarUrl,
            name: person.fullName,
            size: 28,
            gender: person.gender,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              person.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 16.sp,
        color: AppColors.textHint,
      ),
    );
  }
}
