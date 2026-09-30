import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/family_member.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

/// ສະແດງລາຍລະອຽດຂອງ node ໃນຜັງ (ເມື່ອກົດ)
/// - Admin: ມີປຸ່ມແກ້ໄຂ / ລຶບ
/// - Member: ເບິ່ງໄດ້ຢ່າງດຽວ (read-only)
///
/// [allMembers] ສົ່ງມາເພື່ອສະແດງຊື່ຄວາມສຳພັນ (ຖ້າບໍ່ສົ່ງ ຈະດຶງເອງຈາກ repository)
Future<void> showMemberDetailSheet(
  FamilyMember member, {
  List<FamilyMember>? allMembers,
  VoidCallback? onChanged,
}) async {
  final isAdmin = AuthService.to.isAdmin;

  List<FamilyMember> members = allMembers ?? const [];
  if (members.isEmpty && AuthService.to.familyId.isNotEmpty) {
    members = await MemberRepository().fetchAll(AuthService.to.familyId);
  }

  return Get.bottomSheet<void>(
    DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _MemberDetailBody(
        member: member,
        isAdmin: isAdmin,
        allMembers: members,
        scrollController: scrollController,
        onChanged: onChanged,
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _MemberDetailBody extends StatelessWidget {
  const _MemberDetailBody({
    required this.member,
    required this.isAdmin,
    required this.allMembers,
    required this.scrollController,
    this.onChanged,
  });

  final FamilyMember member;
  final bool isAdmin;
  final List<FamilyMember> allMembers;
  final ScrollController scrollController;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final byId = {for (final m in allMembers) m.id: m};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
              children: [
                // ---------- ຫົວບັດ ----------
                Row(
                  children: [
                    AppAvatar(
                      imageUrl: member.avatarUrl,
                      name: member.fullName,
                      size: 76,
                      gender: member.gender,
                      status: member.status,
                      isAdmin: member.isAccountHolder,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.fullName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if ((member.nickname ?? '').isNotEmpty) ...[
                            SizedBox(height: 3.h),
                            Text(
                              'ຊື່ຫຼິ້ນ: ${member.nickname}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children: [
                              GenderBadge(gender: member.gender),
                              StatusBadge(status: member.status),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  member.generationLabel,
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                // ---------- ຂໍ້ມູນພື້ນຖານ ----------
                _sectionCard(
                  title: AppStrings.personInfo,
                  icon: Icons.badge_outlined,
                  children: [
                    _row(
                        Icons.cake_outlined,
                        'ວັນເກີດ',
                        member.birthDate == null
                            ? '-'
                            : AppDateUtils.format(member.birthDate)),
                    if (member.birthDate != null)
                      _row(
                          Icons.timelapse_rounded,
                          'ອາຍຸ',
                          AppDateUtils.ageLabel(member.birthDate,
                              deathDate: member.deathDate)),
                    if (member.deathDate != null)
                      _row(Icons.spa_rounded, 'ວັນເສຍຊີວິດ',
                          AppDateUtils.format(member.deathDate)),
                    if ((member.occupation ?? '').isNotEmpty)
                      _row(Icons.work_outline_rounded, 'ອາຊີບ',
                          member.occupation!),
                    if ((member.address ?? '').isNotEmpty)
                      _row(Icons.location_on_outlined, 'ທີ່ຢູ່',
                          member.address!),
                    if ((member.note ?? '').isNotEmpty)
                      _row(Icons.notes_rounded, 'ໝາຍເຫດ', member.note!),
                  ],
                ),
                SizedBox(height: 12.h),

                // ---------- ຂໍ້ມູນຕິດຕໍ່ ----------
                if ((member.phone ?? '').isNotEmpty ||
                    (member.whatsapp ?? '').isNotEmpty)
                  _sectionCard(
                    title: 'ຂໍ້ມູນຕິດຕໍ່',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      if ((member.phone ?? '').isNotEmpty)
                        _actionRow(
                          icon: Icons.call_outlined,
                          label: 'ເບີໂທ',
                          value: member.phone!,
                          onTap: () => _launch('tel:${member.phone}'),
                        ),
                      if ((member.whatsapp ?? '').isNotEmpty)
                        _actionRow(
                          icon: Icons.chat_outlined,
                          label: 'WhatsApp',
                          value: member.whatsapp!,
                          color: const Color(0xFF25D366),
                          onTap: () => _launch(
                              'https://wa.me/${Validators.toWhatsApp(member.whatsapp!)}'),
                        ),
                    ],
                  ),
                if ((member.phone ?? '').isNotEmpty ||
                    (member.whatsapp ?? '').isNotEmpty)
                  SizedBox(height: 12.h),

                // ---------- ຄວາມສຳພັນ ----------
                _sectionCard(
                  title: AppStrings.relationships,
                  icon: Icons.hub_outlined,
                  children: [
                    if (member.fatherId != null &&
                        byId[member.fatherId] != null)
                      _relationRow(Icons.man_rounded, AppStrings.father,
                          byId[member.fatherId]!),
                    if (member.motherId != null &&
                        byId[member.motherId] != null)
                      _relationRow(Icons.woman_rounded, AppStrings.mother,
                          byId[member.motherId]!),
                    if (member.spouseIds.isNotEmpty)
                      _relationsRow(
                          Icons.favorite_rounded,
                          AppStrings.spouse,
                          member.spouseIds
                              .map((id) => byId[id])
                              .whereType<FamilyMember>()
                              .toList()),
                    if (member.childIds.isNotEmpty)
                      _relationsRow(
                          Icons.child_care_rounded,
                          AppStrings.children,
                          member.childIds
                              .map((id) => byId[id])
                              .whereType<FamilyMember>()
                              .toList()),
                    if (fatherMissing(byId) &&
                        member.fatherId == null &&
                        member.motherId == null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Text(
                          'ບໍ່ມີຂໍ້ມູນພໍ່ແມ່ (ອາດເປັນຮາກຂອງຄອບຄົວ)',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColors.textHint),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 18.h),

                // ---------- ປຸ່ມຈັດການ ----------
                if (member.linkedUserId != null)
                  FutureBuilder<AppUser?>(
                    future: UserRepository().fetch(member.linkedUserId!),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      if (user == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          _linkedAccountCard(user),
                          SizedBox(height: 12.h),
                        ],
                      );
                    },
                  ),
                if (isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Get.back();
                            Get.toNamed(
                              Routes.MEMBER_FORM,
                              arguments: {
                                'memberId': member.id,
                                'familyId': member.familyId
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text(AppStrings.editNode),
                          style: FilledButton.styleFrom(
                              minimumSize: Size.fromHeight(50.h)),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteMember(context),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: const Text(AppStrings.deleteNode),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(50.h),
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 16.sp, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            AppStrings.readOnlyBanner,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ລຶບສະມາຊິກອອກຈາກຜັງ (Admin ເທົ່ານັ້ນ)
  Future<void> _deleteMember(BuildContext context) async {
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບ ${member.fullName}?',
      message: 'ການລຶບຈະລຶບຄວາມສຳພັນທີ່ອ້າງອີງເຖິງສະມາຊິກຄົນນີ້ນຳ',
      confirmText: 'ລຶບ',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;

    try {
      UiHelpers.loading(message: 'ກຳລັງລຶບ...');
      await MemberRepository().deleteMember(
        familyId: member.familyId,
        memberId: member.id,
        allMembers: allMembers,
      );
      UiHelpers.hideLoading();
      Get.back();
      UiHelpers.success('ລຶບ ${member.fullName} ສຳເລັດ');
      onChanged?.call();
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  bool fatherMissing(Map<String, FamilyMember> byId) =>
      (member.fatherId == null || byId[member.fatherId] == null) &&
      (member.motherId == null || byId[member.motherId] == null);

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      UiHelpers.error('ບໍ່ສາມາດເປີດລິ້ງໄດ້');
    }
  }

  Widget _linkedAccountCard(AppUser user) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        ),
        child: Row(
          children: [
            Icon(Icons.link_rounded, size: 17.sp, color: AppColors.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ຜູກກັບບັນຊີເຂົ້າລະບົບ',
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            RoleBadge(role: user.role, compact: true),
          ],
        ),
      );

  Widget _sectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(15.w),
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
              Icon(icon, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textHint),
            SizedBox(width: 10.w),
            SizedBox(
              width: 90.w,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5.sp, color: AppColors.textSecondary)),
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
          ],
        ),
      );

  Widget _actionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, size: 14.sp, color: color),
              ),
              SizedBox(width: 11.w),
              SizedBox(
                width: 74.w,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12.5.sp, color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  size: 14.sp, color: AppColors.textHint),
            ],
          ),
        ),
      );

  Widget _relationRow(IconData icon, String label, FamilyMember person) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textHint),
            SizedBox(width: 10.w),
            SizedBox(
              width: 90.w,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5.sp, color: AppColors.textSecondary)),
            ),
            AppAvatar(
              imageUrl: person.avatarUrl,
              name: person.fullName,
              size: 26,
              gender: person.gender,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                person.fullName,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _relationsRow(
          IconData icon, String label, List<FamilyMember> people) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15.sp, color: AppColors.textHint),
                SizedBox(width: 10.w),
                Text(
                  '$label (${people.length})',
                  style: TextStyle(
                      fontSize: 12.5.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                for (final person in people)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      person.fullName,
                      style: TextStyle(
                          fontSize: 11.5.sp, color: AppColors.textPrimary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}
