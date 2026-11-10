import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/member_tile.dart';
// import '../../../core/widgets/segmented_control.dart';
import '../component/member_account_tile.dart';
import '../component/member_role_filter.dart';
import '../component/members_header.dart';
import '../controllers/members_controller.dart';

/// ໜ້າສະມາຊິກ (UI ຮ່ວມກັນ ແຍກສິດຕາມ role)
/// - Admin: ສ້າງບັນຊີ member + ອັບເດດ/ແກ້ໄຂ/ລຶບ
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
              heroTag: 'members_fab',
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
            Obx(
              () => MembersHeader(
                isAdmin: isAdmin,
                memberCount: controller.accounts
                    .where((user) => user.uid != controller.myUid)
                    .length,
                searchController: controller.searchController,
              ),
            ),
            // Obx(
            //   () => SegmentedControl<MemberListMode>(
            //     margin: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 4.h),
            //     selected: controller.mode.value,
            //     onChanged: controller.changeMode,
            //     options: const [
            //       // SegmentedOption(
            //       //   value: MemberListMode.accounts,
            //       //   label: 'ບັນຊີສະມາຊິກ',
            //       //   icon: Icons.badge_outlined,
            //       // ),
            //       // SegmentedOption(
            //       //   value: MemberListMode.tree,
            //       //   label: 'ທັງໝົດໃນຜັງ',
            //       //   icon: Icons.account_tree_outlined,
            //       // ),
            //     ],
            //   ),
            // ),
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

  Widget _accountsList(bool isAdmin) {
    final accounts = controller.filteredAccounts;

    return Column(
      children: [
        Obx(
          () => MemberRoleFilter(
            selected: controller.roleFilter.value,
            onChanged: controller.setRoleFilter,
          ),
        ),
        Expanded(
          child: accounts.isEmpty
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
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return MemberAccountTile(
                          user: account,
                          isAdmin: isAdmin,
                          onTap: () => controller.openDetail(account),
                          onChat: () => controller.openChat(account),
                          onDetail: () => controller.openDetail(account),
                          onEdit: () => controller.openEdit(account),
                          onDelete: () => controller.deleteAccount(account),
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

  Widget _treeList() {
    final members = controller.filteredTreeMembers;
    if (members.isEmpty) {
      return const EmptyState(
        title: 'ຍັງບໍ່ມີສະມາຊິກໃນຜັງ',
        icon: Icons.account_tree_outlined,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) =>
          MemberTile(
                member: members[index],
                onTap: () => controller.openPersonDetail(members[index]),
              )
              .animate(delay: (index * 45).ms)
              .fadeIn(duration: 320.ms)
              .slideX(begin: 0.05, end: 0),
    );
  }
}
