import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/family_member.dart';
import '../../../data/models/enums.dart';
import '../controllers/family_tree_controller.dart';

/// ກາດສະມາຊິກໃນຜັງຄອບຄົວ — ຮັກສາຂະໜາດເພື່ອໃຫ້ layout ເດີມເຮັດວຽກຄືເກົ່າ.
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
    final accent = _accent;
    final borderColor = isHighlighted
        ? AppColors.accent
        : isSelected
        ? AppColors.primary
        : accent.withValues(alpha: 0.34);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${member.fullName}, ${member.generationLabel}',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: FamilyTreeController.nodeWidth,
          height: FamilyTreeController.nodeHeight,
          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: borderColor,
              width: isSelected || isHighlighted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? AppColors.primary : AppColors.primaryDark)
                    .withValues(alpha: isSelected ? 0.18 : 0.07),
                blurRadius: isSelected ? 17 : 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 3.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.38),
                        width: 1.2,
                      ),
                      color: accent.withValues(alpha: 0.06),
                    ),
                    child: AppAvatar(
                      imageUrl: member.avatarUrl,
                      name: member.fullName,
                      size: 44,
                      gender: member.gender,
                      status: member.status,
                      showStatusBadge: true,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  Positioned(
                    right: -4.w,
                    top: -3.h,
                    child: Container(
                      width: 19.w,
                      height: 19.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Icon(
                        member.gender == Gender.female
                            ? Icons.female_rounded
                            : Icons.male_rounded,
                        size: 13.sp,
                        color: accent,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      left: -3.w,
                      top: -3.h,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (member.status == MemberStatus.deceased)
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppColors.deceased.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                member.fullName,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: AppColors.textPrimary,
                  decoration: member.isDeceased
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const Spacer(),
              Text(
                member.birthDate == null
                    ? member.generationLabel
                    : '${AppDateUtils.age(member.birthDate, deathDate: member.deathDate)} ປີ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  member.status.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
