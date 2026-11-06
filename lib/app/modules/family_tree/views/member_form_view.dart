import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/member_form_controller.dart';
import '../widgets/member_form/member_account_link_section.dart';
import '../widgets/member_form/member_avatar_picker.dart';
import '../widgets/member_form/member_basic_info_section.dart';
import '../widgets/member_form/member_contact_section.dart';
import '../widgets/member_form/member_form_bottom_bar.dart';
import '../widgets/member_form/member_relationships_section.dart';
import '../widgets/member_form/member_status_section.dart';

/// ຟອມເພີ່ມ / ແກ້ໄຂ ສະມາຊິກໃນຜັງ (Admin)
///
/// ໄຟລ໌ນີ້ເປັນພຽງ orchestrator. ແຕ່ລະພາກຖືກແຍກໄປຢູ່ widgets/member_form/.
class MemberFormView extends GetView<MemberFormController> {
  const MemberFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.isEdit ? AppStrings.editNode : AppStrings.addNode,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: controller.formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ຮູບໂປຣໄຟລ໌ + ປຸ່ມເລືອກ/ປ່ຽນຮູບ
                    const MemberAvatarPicker(),
                    SizedBox(height: 20.h),
                    // ຂໍ້ມູນພື້ນຖານ: ຊື່, ຊື່ຫຼິ້ນ, ເພດ, ວັນເກີດ, ລຸ້ນ
                    const MemberBasicInfoSection(),
                    SizedBox(height: 14.h),
                    // ສະຖານະ
                    const MemberStatusSection(),
                    SizedBox(height: 14.h),
                    // ຄວາມສຳພັນ: ພໍ່, ແມ່, ຄູ່, ລູກ, ເພື່ອນ
                    const MemberRelationshipsSection(),
                    SizedBox(height: 14.h),
                    // ຂໍ້ມູນຕິດຕໍ່: ເບີໂທ, ອີເມວ, ທີ່ຢູ່
                    const MemberContactSection(),
                    SizedBox(height: 14.h),
                    // ການເຊື່ອມບັນຊີ: ເຊື່ອມບັນຊີ Google, Facebook, Apple

                    const MemberAccountLinkSection(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const MemberFormBottomBar(),
    );
  }
}
