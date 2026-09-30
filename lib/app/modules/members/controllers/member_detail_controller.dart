import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

/// ລາຍລະອຽດຂອງສະມາຊິກ (ທັງບັນຊີ ແລະ ບຸກຄົນໃນຜັງ)
class MemberDetailController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final MemberRepository _memberRepo = MemberRepository();
  final ChatRepository _chatRepo = ChatRepository();

  StreamSubscription<List<AppUser>>? _usersSub;
  StreamSubscription<List<FamilyMember>>? _membersSub;

  final Rxn<AppUser> account = Rxn<AppUser>();
  final Rxn<FamilyMember> person = Rxn<FamilyMember>();
  final RxList<FamilyMember> allMembers = <FamilyMember>[].obs;
  final RxList<AppUser> allAccounts = <AppUser>[].obs;
  final RxBool isLoading = true.obs;
  final RxString type = 'account'.obs;
  final RxString id = ''.obs;

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;
  String get myUid => AuthService.to.uid;
  bool get isSelf => account.value?.uid == myUid;
  bool get canChat => account.value != null && !isSelf;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      type.value = (args['type'] ?? 'account') as String;
      id.value = (args['uid'] ?? args['memberId'] ?? '') as String;
    }
    _listen();
  }

  void _listen() {
    final fid = familyId;
    if (fid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _usersSub = _userRepo.usersStream(fid).listen((list) {
      allAccounts.assignAll(list);
      if (type.value == 'account') {
        for (final u in list) {
          if (u.uid == id.value) {
            account.value = u;
            break;
          }
        }
      } else if (person.value?.linkedUserId != null) {
        for (final u in list) {
          if (u.uid == person.value!.linkedUserId) {
            account.value = u;
            break;
          }
        }
      }
      isLoading.value = false;
    });

    _membersSub = _memberRepo.membersStream(fid).listen((list) {
      allMembers.assignAll(list);
      if (type.value == 'person') {
        for (final m in list) {
          if (m.id == id.value) {
            person.value = m;
            break;
          }
        }
      } else if (account.value?.memberId != null) {
        for (final m in list) {
          if (m.id == account.value!.memberId) {
            person.value = m;
            break;
          }
        }
      }

      // ຜູກບຸກຄົນໃນຜັງກັບບັນຊີ
      if (person.value != null &&
          account.value == null &&
          person.value!.linkedUserId != null) {
        for (final u in allAccounts) {
          if (u.uid == person.value!.linkedUserId) {
            account.value = u;
            break;
          }
        }
      }
      isLoading.value = false;
    });
  }

  Future<void> openChat() async {
    final other = account.value;
    if (other == null || isSelf) return;
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

  Future<void> call(String phone) async {
    if (phone.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$phone'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      UiHelpers.error('ບໍ່ສາມາດໂທອອກໄດ້');
    }
  }

  Future<void> openWhatsApp(String number) async {
    if (number.isEmpty) return;
    final url = 'https://wa.me/${Validators.toWhatsApp(number)}';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      UiHelpers.error('ບໍ່ສາມາດເປີດ WhatsApp ໄດ້');
    }
  }

  Future<void> sendEmail(String email) async {
    if (email.isEmpty) return;
    try {
      await launchUrl(Uri.parse('mailto:$email'));
    } catch (_) {
      UiHelpers.error('ບໍ່ສາມາດສົ່ງອີແມວໄດ້');
    }
  }

  void editAccount() {
    if (!isAdmin) {
      UiHelpers.error('ສະເພາະ Admin ຈຶ່ງແກ້ໄຂບັນຊີໄດ້');
      return;
    }
    Get.toNamed(Routes.ACCOUNT_FORM, arguments: {'uid': account.value?.uid});
  }

  void editPerson() {
    if (!isAdmin) {
      UiHelpers.error('ສະເພາະ Admin ຈຶ່ງແກ້ໄຂຜັງໄດ້');
      return;
    }
    Get.toNamed(Routes.MEMBER_FORM, arguments: {'memberId': person.value?.id});
  }

  Future<void> deleteAccount() async {
    final user = account.value;
    if (user == null || !isAdmin) return;
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບບັນຊີ ${user.displayName}?',
      message: 'ບັນຊີນີ້ຈະຖືກລຶບອອກຈາກລະບົບ',
      confirmText: 'ລຶບ',
      isDanger: true,
      icon: Icons.person_remove_rounded,
    );
    if (!confirmed) return;
    try {
      UiHelpers.loading();
      await _userRepo.deleteMemberAccount(user.uid, familyId: familyId);
      UiHelpers.hideLoading();
      UiHelpers.success('ລຶບບັນຊີສຳເລັດ');
      Get.back();
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  Future<void> deletePerson() async {
    final member = person.value;
    if (member == null || !isAdmin) return;
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບ ${member.fullName}?',
      message: 'ສະມາຊິກຄົນນີ້ຈະຖືກລຶບອອກຈາກຜັງ',
      confirmText: 'ລຶບ',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    try {
      UiHelpers.loading();
      await _memberRepo.deleteMember(
        familyId: familyId,
        memberId: member.id,
        allMembers: allMembers,
      );
      UiHelpers.hideLoading();
      UiHelpers.success('ລຶບສຳເລັດ');
      Get.back();
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  // ຄວາມສຳພັນຂອງບຸກຄົນ
  FamilyMember? get father => _find(person.value?.fatherId);
  FamilyMember? get mother => _find(person.value?.motherId);
  List<FamilyMember> get spouses =>
      person.value?.spouseIds.map(_find).whereType<FamilyMember>().toList() ??
      [];
  List<FamilyMember> get children =>
      person.value?.childIds.map(_find).whereType<FamilyMember>().toList() ??
      [];
  List<FamilyMember> get siblings =>
      person.value?.siblingIds.map(_find).whereType<FamilyMember>().toList() ??
      [];

  FamilyMember? _find(String? id) {
    if (id == null) return null;
    for (final m in allMembers) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    _membersSub?.cancel();
    super.onClose();
  }
}
