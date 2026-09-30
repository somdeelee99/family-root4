import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/family_member.dart';
import '../../../data/models/enums.dart';
import '../controllers/family_tree_controller.dart';

/// ກາດ node ຂອງສະມາຊິກໃນຜັງໄມ້ຄອບຄົວ
class TreeNodeCard extends StatelessWidget {
  const TreeNodeCard({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isHighlighted,
    this.onTap,
    this.onLongPress,
    this.showAdminMenu = false,
  });

  final FamilyMember member;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showAdminMenu;

  Color get _accent {
    if (member.isDeceased) return AppColors.deceased;
    return AppColors.forGender(member.gender.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: FamilyTreeController.nodeWidth,
        height: FamilyTreeController.nodeHeight,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isHighlighted
                ? AppColors.accent
                : isSelected
                    ? AppColors.primary
                    : AppColors.divider,
            width: isSelected || isHighlighted ? 2.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.primary : AppColors.primaryDark)
                  .withValues(alpha: isSelected ? 0.22 : 0.09),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  imageUrl: member.avatarUrl,
                  name: member.fullName,
                  size: 46,
                  gender: member.gender,
                  status: member.status,
                  showStatusBadge: true,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                if (member.status == MemberStatus.deceased)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.deceased.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(Icons.spa_rounded,
                          color: Colors.white, size: 20.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              member.fullName,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: AppColors.textPrimary,
                decoration:
                    member.isDeceased ? TextDecoration.lineThrough : null,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              member.birthDate == null
                  ? member.generationLabel
                  : '${AppDateUtils.age(member.birthDate, deathDate: member.deathDate)} ປີ',
              style:
                  TextStyle(fontSize: 9.5.sp, color: AppColors.textSecondary),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    member.gender == Gender.female
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    size: 10.sp,
                    color: _accent,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    member.status.shortLabel,
                    style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w700,
                        color: _accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
