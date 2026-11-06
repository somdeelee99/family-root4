import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/member_tile.dart';
import '../../../data/models/family_member.dart';
import '../controllers/family_tree_controller.dart';
import 'member_detail_sheet.dart';

/// ໂໝດລາຍການ: ສະແດງສະມາຊິກແຍກຕາມລຸ້ນ ແລະ ກັ່ນຕອງຕາມຄຳຄົ້ນຫາ.
class FamilyTreeListView extends GetView<FamilyTreeController> {
  const FamilyTreeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final grouped = controller.groupedByGeneration;
      if (grouped.isEmpty) {
        return const EmptyState(
          title: AppStrings.noMembers,
          icon: Icons.groups_outlined,
        );
      }

      final query = controller.query.value.toLowerCase();
      final visibleGroups = grouped.entries
          .map(
            (entry) => MapEntry(
              entry.key,
              entry.value.where((member) {
                return query.isEmpty ||
                    member.fullName.toLowerCase().contains(query) ||
                    (member.nickname ?? '').toLowerCase().contains(query);
              }).toList(),
            ),
          )
          .where((entry) => entry.value.isNotEmpty)
          .toList();

      if (visibleGroups.isEmpty) {
        return EmptyState(
          title: 'ບໍ່ພົບສະມາຊິກ',
          description: 'ລອງຄົ້ນຫາດ້ວຍຊື່ ຫຼື ຊື່ຫຼິ້ນອື່ນ',
          icon: Icons.search_off_rounded,
          actionLabel: 'ລ້າງຄຳຄົ້ນຫາ',
          onAction: controller.clearSearch,
        );
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 90.h),
        physics: const BouncingScrollPhysics(),
        children: [
          _listHeader(
            query: query,
            count: visibleGroups.fold<int>(
              0,
              (sum, group) => sum + group.value.length,
            ),
          ),
          for (final entry in visibleGroups) ...[
            _generationHeader(entry.key, entry.value.length),
            SizedBox(height: 10.h),
            for (final member in entry.value)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: MemberTile(
                  member: member,
                  onTap: () => _openDetail(member),
                ),
              ),
            SizedBox(height: 14.h),
          ],
        ],
      ).animate().fadeIn(duration: 300.ms);
    });
  }

  Widget _listHeader({required String query, required int count}) => Padding(
    padding: EdgeInsets.only(bottom: 14.h),
    child: Row(
      children: [
        Icon(Icons.groups_2_rounded, size: 17.sp, color: AppColors.primary),
        SizedBox(width: 7.w),
        Text(
          query.isEmpty ? 'ສະມາຊິກທັງໝົດ' : 'ຜົນການຄົ້ນຫາ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count ຄົນ',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _generationHeader(int generation, int count) => Row(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          'ລຸ້ນທີ $generation',
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        '$count ຄົນ',
        style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
      ),
    ],
  );

  void _openDetail(FamilyMember member) {
    controller.selected.value = member;
    showMemberDetailSheet(
      member,
      allMembers: controller.members,
      onChanged: controller.refreshSelected,
    );
  }
}
