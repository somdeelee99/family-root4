import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/family_member.dart';
import '../../family_tree/widgets/member_detail_sheet.dart';
import '../controllers/member_detail_controller.dart';

/// ພາກຂໍ້ມູນບຸກຄົນໃນຜັງ (ສຳລັບໜ້າລາຍລະອຽດ)
class PersonInfoSection extends StatelessWidget {
  const PersonInfoSection(
      {super.key, required this.person, required this.controller});

  final FamilyMember person;
  final MemberDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _card(
          title: AppStrings.personInfo,
          icon: Icons.badge_outlined,
          children: [
            _row(
                Icons.cake_outlined,
                'ວັນເກີດ',
                person.birthDate == null
                    ? '-'
                    : AppDateUtils.format(person.birthDate)),
            if (person.birthDate != null)
              _row(
                  Icons.timelapse_rounded,
                  'ອາຍຸ',
                  AppDateUtils.ageLabel(person.birthDate,
                      deathDate: person.deathDate)),
            if (person.deathDate != null)
              _row(Icons.spa_rounded, 'ວັນເສຍຊີວິດ',
                  AppDateUtils.format(person.deathDate)),
            if ((person.occupation ?? '').isNotEmpty)
              _row(Icons.work_outline_rounded, 'ອາຊີບ', person.occupation!),
            if ((person.address ?? '').isNotEmpty)
              _row(Icons.location_on_outlined, 'ທີ່ຢູ່', person.address!),
            if ((person.note ?? '').isNotEmpty)
              _row(Icons.notes_rounded, 'ໝາຍເຫດ', person.note!),
          ],
        ),
        if (controller.father != null ||
            controller.mother != null ||
            controller.spouses.isNotEmpty) ...[
          SizedBox(height: 14.h),
          _card(
            title: AppStrings.relationships,
            icon: Icons.hub_outlined,
            children: [
              if (controller.father != null)
                _personRow(
                    Icons.man_rounded, AppStrings.father, controller.father!),
              if (controller.mother != null)
                _personRow(
                    Icons.woman_rounded, AppStrings.mother, controller.mother!),
              for (final spouse in controller.spouses)
                _personRow(Icons.favorite_rounded, AppStrings.spouse, spouse),
              for (final child in controller.children)
                _personRow(
                    Icons.child_care_rounded, AppStrings.children, child),
              for (final sibling in controller.siblings)
                _personRow(
                    Icons.people_outline_rounded, AppStrings.siblings, sibling),
            ],
          ),
        ],
      ],
    );
  }

  Widget _card(
          {required String title,
          required IconData icon,
          required List<Widget> children}) =>
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textHint),
            SizedBox(width: 10.w),
            SizedBox(
              width: 96.w,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5.sp, color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _personRow(IconData icon, String label, FamilyMember person) =>
      InkWell(
        onTap: () =>
            showMemberDetailSheet(person, allMembers: controller.allMembers),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              Icon(icon, size: 15.sp, color: AppColors.textHint),
              SizedBox(width: 10.w),
              SizedBox(
                width: 96.w,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12.5.sp, color: AppColors.textSecondary)),
              ),
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
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 16.sp, color: AppColors.textHint),
            ],
          ),
        ),
      );
}
