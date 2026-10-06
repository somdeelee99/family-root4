import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// ຄວບຄຸມຫ້ອງສົນທະນາ 1:1
/// - ສົ່ງຂໍ້ຄວາມ (text / ຮູບພາບ + emoji)
/// - ແຈ້ງເຕືອນໄປຫາຜູ້ຮັບ (ຜ່ານ Cloud Function trigger + FCM)
/// - ເຫັນປະຫວັດການສົນທະນາ ແລະ ບໍ່ສາມາດລຶບຂໍ້ຄວາມໄດ້
class ChatRoomController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rxn<AppUser> otherUser = Rxn<AppUser>();
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool showEmojiPicker = false.obs;

  late String roomId;
  late String otherUid;

  String get familyId => AuthService.to.familyId;
  String get myUid => AuthService.to.uid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      roomId = (args['roomId'] ?? '') as String;
      otherUid = (args['otherUid'] ?? '') as String;
    } else if (args is String) {
      roomId = args;
      otherUid = args
          .split('__')
          .firstWhere((id) => id != myUid, orElse: () => '');
    }

    _listen();
    _loadOtherUser();
    _markRead();
  }

  void _listen() {
    if (roomId.isEmpty) {
      isLoading.value = false;
      return;
    }
    _messagesSub = _chatRepo
        .messagesStream(familyId, roomId)
        .listen(
          (list) {
            messages.assignAll(list);
            isLoading.value = false;
            _scrollToBottom();
            _markRead();
          },
          onError: (Object e) {
            isLoading.value = false;
            UiHelpers.error(UiHelpers.mapError(e));
          },
        );
  }

  Future<void> _loadOtherUser() async {
    if (otherUid.isEmpty) return;
    otherUser.value = await _userRepo.fetch(otherUid);
  }

  Future<void> _markRead() async {
    if (roomId.isEmpty) return;
    try {
      await _chatRepo.markAsRead(
        familyId: familyId,
        roomId: roomId,
        uid: myUid,
      );
    } catch (_) {
      // ຂ້າມຖ້າບໍ່ສຳເລັດ
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final auth = AuthService.to;
    final user = auth.user.value;
    if (user == null) return;

    textController.clear();
    isSending.value = true;
    try {
      await _chatRepo.sendMessage(
        familyId: familyId,
        roomId: roomId,
        senderId: myUid,
        senderName: user.displayName,
        senderAvatar: user.avatarUrl,
        senderRole: user.role,
        text: text,
      );
      showEmojiPicker.value = false;
    } catch (e) {
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSending.value = false;
    }
  }

  /// ສົ່ງຮູບພາບໃນການສົນທະນາ
  Future<void> sendImage({ImageSource source = ImageSource.gallery}) async {
    final user = AuthService.to.user.value;
    if (user == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    isSending.value = true;
    UiHelpers.loading(message: 'ກຳລັງອັບໂຫຼດຮູບ...');
    try {
      final url = await _storageRepo.uploadChatImage(
        File(picked.path),
        familyId,
        roomId,
      );
      await _chatRepo.sendMessage(
        familyId: familyId,
        roomId: roomId,
        senderId: myUid,
        senderName: user.displayName,
        senderAvatar: user.avatarUrl,
        senderRole: user.role,
        text: '',
        imageUrl: url,
        type: 'image',
      );
      UiHelpers.hideLoading();
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSending.value = false;
    }
  }

  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;
    if (showEmojiPicker.value) FocusManager.instance.primaryFocus?.unfocus();
  }

  void onEmojiSelected(String emoji) => textController.text += emoji;

  /// ບໍ່ອະນຸຍາດໃຫ້ລຶບຂໍ້ຄວາມ (ຕາມຂໍ້ກຳນົດຂອງລະບົບ)
  void tryDeleteMessage(ChatMessage message) {
    UiHelpers.warning(
      'ບໍ່ສາມາດລຶບຂໍ້ຄວາມໄດ້ - ປະຫວັດການສົນທະນາຈະຖືກເກັບຮັກສາໄວ້',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
