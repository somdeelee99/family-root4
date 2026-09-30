import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family_member.dart';
import '../controllers/member_detail_controller.dart';
import '../widgets/person_info_section.dart';

/// ໜ້າລາຍລະອຽດຂອງສະມາຊິກ
/// ທັງ Admin ແລະ Member ເບິ່ງໄດ້ ແລະ ກົດແຊັດຫາໄດ້ (ຍົກເວັ້ນຂໍ້ມູນຂອງຕົນເອງ)
class MemberDetailView extends GetView<MemberDetailController> {
  const MemberDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.memberDetail),
        actions: [
          Obx(
            () => controller.isAdmin
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.type.value == 'account'
                            ? controller.editAccount()
                            : controller.editPerson();
                      } else if (value == 'delete') {
                        controller.type.value == 'account'
                            ? controller.deleteAccount()
                            : controller.deletePerson();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('ແກ້ໄຂຂໍ້ມູນ'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete_outline_rounded,
                              color: Colors.red),
                          title:
                              Text('ລຶບ', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final account = controller.account.value;
        final person = controller.person.value;
        if (account == null && person == null) {
          return const EmptyState(
            title: 'ບໍ່ພົບຂໍ້ມູນສະມາຊິກ',
            description: 'ຂໍ້ມູນອາດຖືກລຶບ ຫຼື ຍ້າຍໄປແລ້ວ',
            icon: Icons.person_search_rounded,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _profileHeader(account: account, person: person),
            SizedBox(height: 16.h),
            if (account != null) _actionsCard(account),
            if (account != null) SizedBox(height: 14.h),
            if (account != null) _accountInfoCard(account),
            if (person != null) ...[
              SizedBox(height: 14.h),
              PersonInfoSection(person: person, controller: controller),
            ],
          ],
        );
      }),
    );
  }

  // ==================== ຫົວບັດ ====================
  Widget _profileHeader({AppUser? account, FamilyMember? person}) {
    final name = account?.displayName ?? person?.fullName ?? '';
    final avatar = account?.avatarUrl ?? person?.avatarUrl;
    final subtitle =
        account?.email ?? (person != null ? person.generationLabel : '');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        children: [
          AppAvatar(
            imageUrl: avatar,
            name: name,
            size: 92,
            gender: person?.gender ??
                (account?.gender == null
                    ? null
                    : Gender.fromString(account!.gender)),
            status: person?.status,
            showStatusBadge: person != null,
            isAdmin: account?.isAdmin ?? false,
            borderRadius: BorderRadius.circular(28.r),
          ),
          SizedBox(height: 14.h),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if ((subtitle ?? '').isNotEmpty) ...[
            SizedBox(height: 5.h),
            Text(
              subtitle!,
              style: TextStyle(
                  fontSize: 12.5.sp,
                  color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              if (account != null) RoleBadge(role: account.role),
              if (person != null) GenderBadge(gender: person.gender),
              if (person != null) StatusBadge(status: person.status),
              if (person != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    person.generationLabel,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ປຸ່ມຕິດຕໍ່ ====================
  Widget _actionsCard(AppUser account) {
    final isSelf = account.uid == AuthService.to.uid;
    final phone = account.phone ?? account.whatsapp ?? '';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (!isSelf)
            Expanded(
              child: _actionButton(
                icon: Icons.forum_rounded,
                label: AppStrings.chatNow,
                color: AppColors.primary,
                onTap: controller.openChat,
              ),
            ),
          if (!isSelf && phone.isNotEmpty) SizedBox(width: 10.w),
          if (phone.isNotEmpty)
            Expanded(
              child: _actionButton(
                icon: Icons.call_rounded,
                label: AppStrings.call,
                color: AppColors.info,
                onTap: () => controller.call(phone),
              ),
            ),
          if ((account.whatsapp ?? '').isNotEmpty) SizedBox(width: 10.w),
          if ((account.whatsapp ?? '').isNotEmpty)
            Expanded(
              child: _actionButton(
                icon: Icons.chat_bubble_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => controller.openWhatsApp(account.whatsapp!),
              ),
            ),
          if (isSelf)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.w),
                alignment: Alignment.center,
                child: Text(
                  'ນີ້ແມ່ນບັນຊີຂອງທ່ານເອງ',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Icon(icon, size: 19.sp, color: color),
              SizedBox(height: 5.h),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ],
          ),
        ),
      );

  // ==================== ຂໍ້ມູນບັນຊີ ====================
  Widget _accountInfoCard(AppUser account) {
    return Container(
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
              Icon(Icons.account_circle_outlined,
                  size: 17.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                AppStrings.accountInfo,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _infoRow(Icons.mail_outline_rounded, AppStrings.email,
              account.email ?? '-',
              onTap: (account.email ?? '').isEmpty
                  ? null
                  : () => controller.sendEmail(account.email!)),
          _infoRow(Icons.call_outlined, AppStrings.phone, account.phone ?? '-',
              onTap: (account.phone ?? '').isEmpty
                  ? null
                  : () => controller.call(account.phone!)),
          _infoRow(
              Icons.chat_outlined, AppStrings.whatsapp, account.whatsapp ?? '-',
              onTap: (account.whatsapp ?? '').isEmpty
                  ? null
                  : () => controller.openWhatsApp(account.whatsapp!)),
          _infoRow(Icons.verified_user_outlined, AppStrings.role,
              account.role.label),
          _infoRow(
            Icons.event_available_outlined,
            'ເຂົ້າໃຊ້ຫຼ້າສຸດ',
            account.lastSeenAt == null
                ? '-'
                : AppDateUtils.relative(account.lastSeenAt),
          ),
          _infoRow(
            Icons.login_rounded,
            'ຊ່ອງທາງເຂົ້າລະບົບ',
            account.providers.isEmpty
                ? '-'
                : account.providers.map((p) => p.label).join(', '),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        child: Row(
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textHint),
            SizedBox(width: 10.w),
            SizedBox(
              width: 96.w,
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 12.5.sp, color: AppColors.textSecondary),
              ),
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
            if (onTap != null)
              Icon(Icons.open_in_new_rounded,
                  size: 13.sp, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
