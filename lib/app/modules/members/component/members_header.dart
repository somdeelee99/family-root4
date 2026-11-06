import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_search_field.dart';

/// ຫົວໜ້າໜ້າສະມາຊິກ: ຊື່ໜ້າ, ຈຳນວນສະມາຊິກ ແລະ ຊ່ອງຄົ້ນຫາ
class MembersHeader extends StatelessWidget {
  const MembersHeader({
    super.key,
    required this.isAdmin,
    required this.memberCount,
    required this.searchController,
  });

  final bool isAdmin;
  final int memberCount;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      icon: Icons.groups_rounded,
      title: AppStrings.members,
      subtitle: isAdmin
          ? 'ຈັດການບັນຊີສະມາຊິກຄອບຄົວ'
          : 'ລາຍຊື່ສະມາຊິກທັງໝົດ',
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          '$memberCount ຄົນ',
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
      bottom: AppSearchField(
        controller: searchController,
        hintText: 'ຄົ້ນຫາຊື່, ເບີໂທ, ອີແມວ...',
      ),
    );
  }
}
