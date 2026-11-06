import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/user_tile.dart';
import '../../../data/models/app_user.dart';

/// ລາຍການບັນຊີສະມາຊິກ ພ້ອມເມນູຈັດການສຳລັບ Admin
class MemberAccountTile extends StatelessWidget {
  const MemberAccountTile({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.onTap,
    required this.onChat,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final AppUser user;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onChat;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return UserTile(
      user: user,
      onTap: onTap,
      onChat: onChat,
      trailing: isAdmin ? _adminMenu() : _chevron(),
    );
  }

  Widget _adminMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20.sp,
        color: AppColors.textHint,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onSelected: (value) {
        switch (value) {
          case 'detail':
            onDetail();
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'detail',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded, size: 20),
            title: Text(AppStrings.seeDetail),
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text(AppStrings.editAccount),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.danger,
            ),
            title: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chevron() => Icon(
    Icons.chevron_right_rounded,
    size: 22.sp,
    color: AppColors.textHint,
  );
}
