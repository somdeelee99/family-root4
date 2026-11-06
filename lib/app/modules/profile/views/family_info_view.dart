import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/info_banner.dart';
import '../component/family_cover_header.dart';
import '../component/family_info_card.dart';
import '../component/family_stats_row.dart';
import '../controllers/family_info_controller.dart';

/// ຂໍ້ມູນຄອບຄົວ (ນາມສະກຸນ ແລະ ລາຍລະອຽດ)
/// Admin ແກ້ໄຂໄດ້, Member ເບິ່ງໄດ້ຢ່າງດຽວ
class FamilyInfoView extends GetView<FamilyInfoController> {
  const FamilyInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.familyInfo),
        actions: [_appBarActions()],
      ),
      body: Obx(() {
        final family = controller.family.value;
        if (family == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              FamilyCoverHeader(
                family: family,
                isEditing: controller.isEditing.value,
                pickedCover: controller.pickedCover.value,
                onPickCover: controller.pickCover,
              ),
              SizedBox(height: 18.h),
              FamilyStatsRow(
                totalMembers: controller.totalMembers,
                generationCount: controller.generationCount,
                maleCount: controller.maleCount,
                femaleCount: controller.femaleCount,
              ),
              SizedBox(height: 18.h),
              FamilyInfoCard(controller: controller, family: family),
              if (!controller.isAdmin) ...[
                SizedBox(height: 14.h),
                const InfoBanner(
                  message:
                      'Member ສາມາດເບິ່ງຂໍ້ມູນຄອບຄົວໄດ້ຢ່າງດຽວ '
                      '(ການແກ້ໄຂເປັນສິດຂອງ Admin)',
                  tone: InfoBannerTone.warning,
                  icon: Icons.lock_outline_rounded,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _appBarActions() {
    return Obx(() {
      if (!controller.isAdmin) return const SizedBox.shrink();

      if (!controller.isEditing.value) {
        return IconButton(
          tooltip: 'ແກ້ໄຂຂໍ້ມູນ',
          onPressed: controller.startEditing,
          icon: const Icon(Icons.edit_outlined),
        );
      }

      return Row(
        children: [
          IconButton(
            tooltip: AppStrings.cancel,
            onPressed: controller.cancelEditing,
            icon: const Icon(Icons.close_rounded),
          ),
          IconButton(
            tooltip: AppStrings.save,
            onPressed: controller.isSaving.value ? null : controller.save,
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
          ),
          SizedBox(width: 6.w),
        ],
      );
    });
  }
}
