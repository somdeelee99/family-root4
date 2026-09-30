import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

enum MemberListMode { accounts, tree }

/// ໜ້າສະມາຊິກ
/// - Admin: ສ້າງ / ແກ້ໄຂ / ລຶບ ບັນຊີສະມາຊິກ, ເບິ່ງລາຍລະອຽດ, ແຊັດຫາ
/// - Member: ເບິ່ງລາຍຊື່ທັງໝົດ, ເບິ່ງລາຍລະອຽດ, ແຊັດຫາ (ບໍ່ສາມາດເພີ່ມ/ແກ້ໄຂ/ລຶບ)
class MembersController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final MemberRepository _memberRepo = MemberRepository();
  final ChatRepository _chatRepo = ChatRepository();

  StreamSubscription<List<AppUser>>? _usersSub;
  StreamSubscription<List<FamilyMember>>? _treeSub;

  final TextEditingController searchController = TextEditingController();

  final RxList<AppUser> accounts = <AppUser>[].obs;
  final RxList<FamilyMember> treeMembers = <FamilyMember>[].obs;
  final RxString query = ''.obs;
  final Rx<MemberListMode> mode = MemberListMode.accounts.obs;
  final RxBool isLoading = true.obs;
  final Rx<UserRole?> roleFilter = Rx<UserRole?>(null);

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;
  String get myUid => AuthService.to.uid;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(
        () => query.value = searchController.text.trim().toLowerCase());
    _listen();
  }

  void _listen() {
    final fid = familyId;
    if (fid.isEmpty) {
      isLoading.value = false;
      return;
    }

    // ສະເພາະບັນຊີທີ່ຢູ່ຄອບຄົວດຽວກັນ (ບໍ່ລວມຕົນເອງໃນການແຊັດ)
    _usersSub = _userRepo.usersStream(fid).listen(
      (list) {
        accounts.assignAll(list);
        isLoading.value = false;
      },
      onError: (Object e) {
        isLoading.value = false;
        UiHelpers.error(UiHelpers.mapError(e));
      },
    );

    _treeSub = _memberRepo
        .membersStream(fid)
        .listen((list) => treeMembers.assignAll(list));
  }

  /// ລາຍຊື່ບັນຊີຕາມການຄົ້ນຫາ ແລະ ການກອງ
  List<AppUser> get filteredAccounts {
    var list = accounts.where((u) => u.uid != myUid).toList();

    if (roleFilter.value != null) {
      list = list.where((u) => u.role == roleFilter.value).toList();
    }
    if (query.value.isEmpty) return list;

    return list
        .where((u) =>
            u.displayName.toLowerCase().contains(query.value) ||
            (u.email ?? '').toLowerCase().contains(query.value) ||
            (u.phone ?? '').contains(query.value) ||
            (u.whatsapp ?? '').contains(query.value))
        .toList();
  }

  /// ສະມາຊິກໃນຜັງທັງໝົດ (ລວມຜູ້ທີ່ຍັງບໍ່ມີບັນຊີ)
  List<FamilyMember> get filteredTreeMembers {
    if (query.value.isEmpty) return treeMembers;
    return treeMembers
        .where((m) =>
            m.fullName.toLowerCase().contains(query.value) ||
            (m.nickname ?? '').toLowerCase().contains(query.value))
        .toList();
  }

  void changeMode(MemberListMode value) {
    mode.value = value;
  }

  void setRoleFilter(UserRole? role) {
    roleFilter.value = roleFilter.value == role ? null : role;
  }

  /// ເປີດຫ້ອງແຊັດກັບສະມາຊິກຄົນນັ້ນ (ບໍ່ສະແດງຂໍ້ມູນຂອງຕົນເອງ)
  Future<void> openChat(AppUser other) async {
    if (other.uid == myUid) {
      UiHelpers.warning('ບໍ່ສາມາດແຊັດຫາຕົນເອງໄດ້');
      return;
    }
    if (other.familyId != familyId) {
      UiHelpers.warning('ສະມາຊິກຄົນນີ້ຢູ່ຄອບຄົວອື່ນ');
      return;
    }
    try {
      UiHelpers.loading(message: 'ກຳລັງເປີດຫ້ອງສົນທະນາ...');
      final roomId = await _chatRepo.openRoom(
        familyId: familyId,
        myUid: myUid,
        otherUid: other.uid,
      );
      UiHelpers.hideLoading();
      Get.toNamed(Routes.CHAT_ROOM,
          arguments: {'roomId': roomId, 'otherUid': other.uid});
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  /// Admin ລຶບບັນຊີສະມາຊິກ
  Future<void> deleteAccount(AppUser user) async {
    if (!isAdmin) {
      UiHelpers.error('ສະເພາະ Admin ຈຶ່ງລຶບບັນຊີໄດ້');
      return;
    }
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບບັນຊີ ${user.displayName}?',
      message: 'ບັນຊີນີ້ຈະຖືກລຶບ ແລະ ບໍ່ສາມາດເຂົ້າລະບົບໄດ້ອີກ',
      confirmText: 'ລຶບ',
      isDanger: true,
      icon: Icons.person_remove_rounded,
    );
    if (!confirmed) return;

    try {
      UiHelpers.loading(message: 'ກຳລັງລຶບບັນຊີ...');
      await _userRepo.deleteMemberAccount(user.uid, familyId: familyId);
      UiHelpers.hideLoading();
      UiHelpers.success('ລຶບບັນຊີ ${user.displayName} ສຳເລັດ');
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  void openDetail(AppUser user) {
    Get.toNamed(Routes.MEMBER_DETAIL,
        arguments: {'uid': user.uid, 'type': 'account'});
  }

  void openPersonDetail(FamilyMember member) {
    Get.toNamed(Routes.MEMBER_DETAIL,
        arguments: {'memberId': member.id, 'type': 'person'});
  }

  void openEdit(AppUser user) {
    if (!isAdmin) {
      UiHelpers.error('ສະເພາະ Admin ຈຶ່ງແກ້ໄຂບັນຊີໄດ້');
      return;
    }
    Get.toNamed(Routes.ACCOUNT_FORM, arguments: {'uid': user.uid});
  }

  void openCreate() {
    if (!isAdmin) {
      UiHelpers.error(AppStrings.memberOnlyNote);
      return;
    }
    Get.toNamed(Routes.ACCOUNT_FORM);
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    _treeSub?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
