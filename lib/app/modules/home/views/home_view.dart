import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/member_tile.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../routes/app_routes.dart';
import '../../shell/controllers/shell_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/gender_donut_chart.dart';
import '../widgets/generation_bar_chart.dart';
import '../widgets/home_stat_grid.dart';

/// ໜ້າຫຼັກ - ສະແດງພາບລວມຂອງຄອບຄົວ
/// Admin ແລະ Member ເຫັນກາຟຂໍ້ມູນດຽວກັນ (ຂໍ້ມູນທັງໝົດ, ອາຍຸຕຳກວ່າ 18, ຊາຍ, ຍິງ, ເສຍຊີວິດ)
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;
    final user = auth.user.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          clipBehavior: Clip.none, // FIX 1
          slivers: [
            // ---------- ຫົວຂໍ້ ----------
            SliverToBoxAdapter(
              child: ClipRRect(
                // FIX 2: ໃຊ້ ClipRRect ແທນ decoration borderRadius
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        14.h,
                        20.w,
                        22.h,
                      ), // FIX 3: ຫຼຸດ 26.h -> 22.h
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // FIX 4
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AppAvatar(
                                imageUrl: user?.avatarUrl,
                                name: user?.displayName ?? '',
                                size: 46,
                                isAdmin: auth.isAdmin,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      user?.displayName ?? AppStrings.appName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (user != null)
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: RoleBadge(role: user.role),
                                ),
                            ],
                          ),
                          SizedBox(height: 18.h),
                          Obx(
                            () => controller.family.value == null
                                ? const SizedBox.shrink()
                                : Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
                                      14.w,
                                    ), // ຫຼຸດ 16 -> 14
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusLg.r,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.park_rounded,
                                              color: Colors.white,
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                controller
                                                    .family
                                                    .value!
                                                    .displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => Get.toNamed(
                                                Routes.FAMILY_INFO,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'ລາຍລະອຽດ',
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 15.sp,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          controller
                                                  .family
                                                  .value!
                                                  .description
                                                  .isEmpty
                                              ? 'ນາມສະກຸນ ${controller.family.value!.surname}'
                                              : controller
                                                    .family
                                                    .value!
                                                    .description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: Colors.white.withValues(
                                              alpha: 0.82,
                                            ),
                                            height: 1.3, // ຫຼຸດ 1.4 -> 1.3
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------- ກາດສະຖິຕິ ----------
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: AppStrings.overview,
                      subtitle: 'ຂໍ້ມູນສະຖິຕິຂອງສະມາຊິກໃນຄອບຄົວ',
                      actionLabel: 'ກາຟ',
                      icon: Icons.insights_rounded,
                      onAction: controller.toggleChartView,
                    ),
                    Obx(
                      () => controller.isLoading.value
                          ? const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const HomeStatGrid(),
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => controller.isChartView.value
                          ? const GenderDonutChart()
                          : const GenerationBarChart(),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => controller.isChartView.value
                          ? const GenerationBarChart()
                          : const GenderDonutChart(),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            if (auth.isAdmin)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: AppStrings.quickActions,
                        icon: Icons.bolt_rounded,
                        subtitle: 'ສິດຂອງ Admin ໃນການຈັດການຄອບຄົວ',
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _quickAction(
                            icon: Icons.person_add_alt_1_rounded,
                            label: AppStrings.addMember,
                            color: AppColors.primary,
                            onTap: () => Get.toNamed(Routes.MEMBER_FORM),
                          ),
                          SizedBox(width: 12.w),
                          _quickAction(
                            icon: Icons.manage_accounts_rounded,
                            label: AppStrings.createAccount,
                            color: AppColors.accent,
                            onTap: () => Get.toNamed(Routes.ACCOUNT_FORM),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'ສະມາຊິກຫຼ້າສຸດ',
                  icon: Icons.history_rounded,
                  actionLabel: 'ເບິ່ງທັງໝົດ',
                  onAction: () {
                    if (Get.isRegistered<ShellController>()) {
                      Get.find<ShellController>().changeTab(2);
                    }
                  },
                ),
              ),
            ),
            Obx(() {
              final recent = controller.recentMembers;
              if (recent.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: EmptyState(
                      title: AppStrings.noMembers,
                      description: AppStrings.noMembersDesc,
                      icon: Icons.group_off_rounded,
                      compact: true,
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) =>
                      MemberTile(
                            member: recent[index],
                            compact: true,
                            onTap: () => Get.toNamed(
                              Routes.MEMBER_DETAIL,
                              arguments: {
                                'memberId': recent[index].id,
                                'type': 'person',
                              },
                            ),
                          )
                          .animate(delay: (index * 60).ms)
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.06, end: 0),
                ),
              );
            }),
            // FIX 5: ເພີ່ມ padding ລຸ່ມສຳລັບ navigation bar
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20.h + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.greetingMorning;
    if (hour < 17) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppSizes.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 19.sp, color: color),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
