import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/member_tile.dart';
import '../../../core/widgets/user_tile.dart';
import '../../../data/models/enums.dart';
import '../controllers/members_controller.dart';

/// ໜ້າສະມາຊິກ (UI ຮ່ວມກັນ ແຍກສິດຕາມ role)
/// - Admin: ສ້າງບັນຊີ member (ຮູບ, ຊື່, ເບີໂທ, whatsapp, ອີແມວ, ລະຫັດ, role) + ອັບເດດ/ແກ້ໄຂ/ລຶບ
/// - Member: ເບິ່ງລາຍຊື່, ເບິ່ງລາຍລະອຽດ, ແຊັດຫາ
class MembersView extends GetView<MembersController> {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.to.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: controller.openCreate,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text(AppStrings.createAccount),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(isAdmin),
            Obx(() => _modeSwitch()),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return controller.mode.value == MemberListMode.accounts
                    ? _accountsList(isAdmin)
                    : _treeList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isAdmin) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.groups_rounded,
                    size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.members,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isAdmin
                          ? 'ຈັດການບັນຊີສະມາຊິກຄອບຄົວ'
                          : 'ລາຍຊື່ສະມາຊິກທັງໝົດ',
                      style: TextStyle(
                          fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    '${controller.accounts.where((u) => u.uid != controller.myUid).length} ຄົນ',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.searchController,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'ຄົ້ນຫາຊື່, ເບີໂທ, ອີແມວ...',
              isDense: true,
              prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
              suffixIcon: Obx(
                () => controller.query.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          controller.searchController.clear();
                          controller.query.value = '';
                        },
                        icon: Icon(Icons.close_rounded, size: 18.sp),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitch() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 4.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _modeItem(
              'ບັນຊີສະມາຊິກ', MemberListMode.accounts, Icons.badge_outlined),
          _modeItem(
              'ທັງໝົດໃນຜັງ', MemberListMode.tree, Icons.account_tree_outlined),
        ],
      ),
    );
  }

  Widget _modeItem(String label, MemberListMode mode, IconData icon) {
    final active = controller.mode.value == mode;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeMode(mode),
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16.sp,
                  color: active ? Colors.white : AppColors.textSecondary),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ລາຍຊື່ບັນຊີ ====================
  Widget _accountsList(bool isAdmin) {
    final list = controller.filteredAccounts;

    return Column(
      children: [
        // ---------- ກອງຕາມ role ----------
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
          child: Row(
            children: [
              Obx(
                () => _filterChip(
                  label: 'ທັງໝົດ',
                  active: controller.roleFilter.value == null,
                  onTap: () => controller.roleFilter.value = null,
                ),
              ),
              SizedBox(width: 8.w),
              Obx(
                () => _filterChip(
                  label: 'Admin',
                  active: controller.roleFilter.value == UserRole.admin,
                  onTap: () => controller.setRoleFilter(UserRole.admin),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(
                () => _filterChip(
                  label: 'Member',
                  active: controller.roleFilter.value == UserRole.member,
                  onTap: () => controller.setRoleFilter(UserRole.member),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  title: AppStrings.noMembers,
                  description: isAdmin
                      ? AppStrings.noMembersDesc
                      : 'ຍັງບໍ່ມີສະມາຊິກໃນຄອບຄົວ',
                  icon: Icons.person_off_outlined,
                  actionLabel: isAdmin ? AppStrings.createAccount : null,
                  onAction: isAdmin ? controller.openCreate : null,
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final user = list[index];
                    return UserTile(
                      user: user,
                      onTap: () => controller.openDetail(user),
                      onChat: () => controller.openChat(user),
                      trailing: isAdmin
                          ? PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded,
                                  size: 20.sp, color: AppColors.textHint),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r)),
                              onSelected: (value) {
                                if (value == 'edit') controller.openEdit(user);
                                if (value == 'delete')
                                  controller.deleteAccount(user);
                                if (value == 'detail')
                                  controller.openDetail(user);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'detail',
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.info_outline_rounded,
                                        size: 20),
                                    title: Text(AppStrings.seeDetail),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading:
                                        Icon(Icons.edit_outlined, size: 20),
                                    title: Text(AppStrings.editAccount),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.delete_outline_rounded,
                                        size: 20, color: Colors.red),
                                    title: Text(AppStrings.delete,
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.chevron_right_rounded,
                              size: 22.sp,
                              color: AppColors.textHint,
                            ),
                    )
                        .animate(delay: (index * 45).ms)
                        .fadeIn(duration: 320.ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(
      {required String label,
      required bool active,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ==================== ລາຍຊື່ທັງໝົດໃນຜັງ ====================
  Widget _treeList() {
    final list = controller.filteredTreeMembers;
    if (list.isEmpty) {
      return const EmptyState(
        title: 'ຍັງບໍ່ມີສະມາຊິກໃນຜັງ',
        icon: Icons.account_tree_outlined,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => MemberTile(
        member: list[index],
        onTap: () => controller.openPersonDetail(list[index]),
      )
          .animate(delay: (index * 45).ms)
          .fadeIn(duration: 320.ms)
          .slideX(begin: 0.05, end: 0),
    );
  }
}
