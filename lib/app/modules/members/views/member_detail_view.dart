import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../component/account_info_card.dart';
import '../component/member_contact_actions.dart';
import '../component/member_detail_menu.dart';
import '../component/member_profile_header.dart';
import '../component/person_info_section.dart';
import '../controllers/member_detail_controller.dart';

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
                ? MemberDetailMenu(
                    onEdit: () => controller.type.value == 'account'
                        ? controller.editAccount()
                        : controller.editPerson(),
                    onDelete: () => controller.type.value == 'account'
                        ? controller.deleteAccount()
                        : controller.deletePerson(),
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
            MemberProfileHeader(account: account, person: person),
            if (account != null) ...[
              SizedBox(height: 16.h),
              MemberContactActions(
                account: account,
                isSelf: account.uid == AuthService.to.uid,
                onChat: () => controller.openChat(),
                onCall: (phone) => controller.call(phone),
                onWhatsApp: (number) => controller.openWhatsApp(number),
              ),
              SizedBox(height: 14.h),
              AccountInfoCard(
                account: account,
                onEmail: controller.sendEmail,
                onCall: controller.call,
                onWhatsApp: controller.openWhatsApp,
              ),
            ],
            if (person != null) ...[
              SizedBox(height: 14.h),
              PersonInfoSection(person: person, controller: controller),
            ],
          ],
        );
      }),
    );
  }
}
