import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/family_member.dart';

/// ເລືອກຄວາມສຳພັນແບບດຽວ (ພໍ່ / ແມ່)
class RelationSinglePicker extends StatelessWidget {
  const RelationSinglePicker({
    super.key,
    required this.label,
    required this.icon,
    required this.members,
    required this.selectedId,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final List<FamilyMember> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    FamilyMember? selected;
    for (final m in members) {
      if (m.id == selectedId) selected = m;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelRow(label, icon),
        SizedBox(height: 7.h),
        InkWell(
          onTap: members.isEmpty ? null : () => _openSheet(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                if (selected != null) ...[
                  AppAvatar(
                    imageUrl: selected.avatarUrl,
                    name: selected.fullName,
                    size: 30,
                    gender: selected.gender,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      selected.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: Text(
                      members.isEmpty
                          ? 'ບໍ່ມີສະມາຊິກໃຫ້ເລືອກ'
                          : 'ເລືອກຈາກລາຍຊື່ທີ່ມີຢູ່',
                      style:
                          TextStyle(fontSize: 13.sp, color: AppColors.textHint),
                    ),
                  ),
                if (selected != null)
                  IconButton(
                    onPressed: () => onChanged(null),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded,
                        size: 18.sp, color: AppColors.textHint),
                  ),
                Icon(Icons.unfold_more_rounded,
                    size: 19.sp, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => _MemberPickSheet(
        title: label,
        members: members,
        selectedIds: selectedId == null ? const [] : [selectedId!],
        multi: false,
        onToggle: (id) {
          onChanged(id);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _labelRow(String label, IconData icon) => Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 7.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'ເລືອກຈາກລາຍຊື່ທີ່ມີຢູ່',
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textHint),
          ),
        ],
      );
}

/// ເລືອກຄວາມສຳພັນແບບຫຼາຍຄົນ (ຜົວ/ເມຍ, ລູກ, ອ້າຍເອື້ອຍນ້ອງ)
class RelationMultiPicker extends StatelessWidget {
  const RelationMultiPicker({
    super.key,
    required this.label,
    required this.icon,
    required this.members,
    required this.selectedIds,
    required this.onToggle,
    this.emptyHint,
  });

  final String label;
  final IconData icon;
  final List<FamilyMember> members;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final selected = members.where((m) => selectedIds.contains(m.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textSecondary),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            if (selectedIds.isNotEmpty) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${selectedIds.length}',
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ],
            const Spacer(),
            InkWell(
              onTap: members.isEmpty ? null : () => _openSheet(context),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded,
                        size: 14.sp, color: AppColors.primary),
                    SizedBox(width: 3.w),
                    Text(
                      'ເພີ່ມ',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (members.isEmpty)
          Text(
            emptyHint ?? 'ບໍ່ມີສະມາຊິກໃຫ້ເລືອກ',
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textHint),
          )
        else if (selected.isEmpty)
          Text(
            'ຍັງບໍ່ໄດ້ເລືອກ',
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textHint),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final member in selected)
                Chip(
                  avatar: AppAvatar(
                    imageUrl: member.avatarUrl,
                    name: member.fullName,
                    size: 22,
                    gender: member.gender,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  label: Text(member.fullName,
                      style: TextStyle(fontSize: 11.5.sp)),
                  labelPadding: EdgeInsets.only(right: 4.w),
                  deleteIcon: Icon(Icons.close_rounded, size: 15.sp),
                  onDeleted: () => onToggle(member.id),
                  side: const BorderSide(color: AppColors.divider),
                  backgroundColor: AppColors.surfaceAlt,
                ),
            ],
          ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => _MemberPickSheet(
          title: label,
          members: members,
          selectedIds: selectedIds,
          multi: true,
          onToggle: (id) {
            onToggle(id);
            setState(() {});
          },
        ),
      ),
    );
  }
}

/// ຊີດເລືອກສະມາຊິກຈາກລາຍຊື່ທີ່ມີຢູ່
class _MemberPickSheet extends StatelessWidget {
  const _MemberPickSheet({
    required this.title,
    required this.members,
    required this.selectedIds,
    required this.multi,
    required this.onToggle,
  });

  final String title;
  final List<FamilyMember> members;
  final List<String> selectedIds;
  final bool multi;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'ເລືອກ$title',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
            Text(
              'ເລືອກຈາກສະມາຊິກທີ່ມີຢູ່ໃນຜັງ ຫຼື ສ້າງໃໝ່ກ່ອນແລ້ວກັບມາເລືອກ',
              style:
                  TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isSelected = selectedIds.contains(member.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => onToggle(member.id),
                    leading: AppAvatar(
                      imageUrl: member.avatarUrl,
                      name: member.fullName,
                      size: 40,
                      gender: member.gender,
                    ),
                    title: Text(
                      member.fullName,
                      style: TextStyle(
                          fontSize: 13.5.sp, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      member.generationLabel,
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                    trailing: Icon(
                      isSelected
                          ? (multi
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_checked_rounded)
                          : (multi
                              ? Icons.circle_outlined
                              : Icons.radio_button_unchecked_rounded),
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
