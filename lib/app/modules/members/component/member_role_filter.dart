import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/app_filter_chip.dart';
import '../../../data/models/enums.dart';

/// ແຖວຕົວກອງບັນຊີຕາມບົດບາດ
class MemberRoleFilter extends StatelessWidget {
  const MemberRoleFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole? selected;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
      child: Row(
        children: [
          AppFilterChip(
            label: 'ທັງໝົດ',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: 'Admin',
            selected: selected == UserRole.admin,
            onTap: () => onChanged(UserRole.admin),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: 'Member',
            selected: selected == UserRole.member,
            onTap: () => onChanged(UserRole.member),
          ),
        ],
      ),
    );
  }
}
