import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

/// ໜ້າສົນທະນາ
/// ທັງ admin ແລະ member ເຫັນລາຍຊື່ສະມາຊິກຄົນອື່ນທັງໝົດ (ບໍ່ລວມຕົນເອງ)
/// ກົດເບິ່ງລາຍລະອຽດ ແລະ ກົດ icon ເພື່ອແຊັດຫາໄດ້
class ChatController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();

  StreamSubscription<List<ChatRoom>>? _roomsSub;
  StreamSubscription<List<AppUser>>? _usersSub;

  final TextEditingController searchController = TextEditingController();

  final RxList<ChatRoom> rooms = <ChatRoom>[].obs;
  final RxList<AppUser> others = <AppUser>[].obs;
  final RxString query = ''.obs;
  final RxBool isLoading = true.obs;

  String get familyId => AuthService.to.familyId;
  String get myUid => AuthService.to.uid;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(
      () => query.value = searchController.text.trim().toLowerCase(),
    );
    _listen();
  }

  void _listen() {
    final fid = familyId;
    if (fid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _roomsSub = _chatRepo.roomsStream(fid, myUid).listen((list) {
      rooms.assignAll(list);
      isLoading.value = false;
    }, onError: (Object e) => isLoading.value = false);

    // ບໍ່ສະແດງຂໍ້ມູນຂອງຕົນເອງ
    _usersSub = _userRepo
        .othersStream(fid, myUid)
        .listen((list) => others.assignAll(list));
  }

  /// ລາຍການຫ້ອງສົນທະນາຕາມການຄົ້ນຫາ
  List<ChatRoom> get filteredRooms {
    if (query.value.isEmpty) return rooms;
    return rooms.where((room) {
      final name = nameOf(room.otherParty(myUid)).toLowerCase();
      return name.contains(query.value) ||
          room.lastMessage.toLowerCase().contains(query.value);
    }).toList();
  }

  AppUser? userOf(String uid) {
    for (final user in others) {
      if (user.uid == uid) return user;
    }
    return null;
  }

  String nameOf(String uid) => userOf(uid)?.displayName ?? 'ສະມາຊິກ';

  /// ຈຳນວນຂໍ້ຄວາມທີ່ຍັງບໍ່ອ່ານທັງໝົດ
  Stream<int> totalUnreadStream() =>
      _chatRepo.totalUnreadStream(familyId, myUid);

  Future<void> openRoomWith(AppUser user) async {
    if (user.uid == myUid) {
      UiHelpers.warning('ບໍ່ສາມາດແຊັດຫາຕົນເອງໄດ້');
      return;
    }
    try {
      final roomId = await _chatRepo.openRoom(
        familyId: familyId,
        myUid: myUid,
        otherUid: user.uid,
      );
      Get.toNamed(
        Routes.CHAT_ROOM,
        arguments: {'roomId': roomId, 'otherUid': user.uid},
      );
    } catch (e) {
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  void openDetail(AppUser user) {
    Get.toNamed(
      Routes.MEMBER_DETAIL,
      arguments: {'uid': user.uid, 'type': 'account'},
    );
  }

  Future<void> deleteRoom(ChatRoom room) async {
    UiHelpers.info('ບໍ່ສາມາດລຶບປະຫວັດການສົນທະນາໄດ້');
  }

  @override
  void onClose() {
    _roomsSub?.cancel();
    _usersSub?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
