import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// ຈັດການການອັບໂຫຼດຮູບພາບຂຶ້ນ Firebase Storage
///
/// ໂຄງສ້າງ:
/// avatars/{uid}/{file}.jpg
/// families/{familyId}/members/{memberId}.jpg
/// families/{familyId}/chat/{roomId}/{file}.jpg
class StorageRepository {
  StorageRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));
  final Uuid _uuid = const Uuid();

  /// ບີບອັດຮູບກ່ອນອັບໂຫຼດ (ຫຼຸດຂະໜາດ ແລະ ຄຸນນະພາບ)
  Future<File> compress(
    File file, {
    int quality = 78,
    int maxWidth = 1280,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/${_uuid.v4()}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        target,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxWidth,
      );
      if (result == null) return file;
      return File(result.path);
    } catch (e) {
      _log.w('ບີບອັດຮູບບໍ່ສຳເລັດ - ໃຊ້ຮູບຕົ້ນສະບັບ: $e');
      return file;
    }
  }

  Future<String> uploadAvatar(File file, String uid) async {
    final compressed = await compress(file, maxWidth: 720);
    final ref = _storage.ref('avatars/$uid/${_uuid.v4()}.jpg');
    return _upload(ref, compressed);
  }

  Future<String> uploadMemberPhoto(
    File file,
    String familyId,
    String memberId,
  ) async {
    final compressed = await compress(file);
    final ref = _storage.ref('families/$familyId/members/$memberId.jpg');
    return _upload(ref, compressed);
  }

  Future<String> uploadChatImage(
    File file,
    String familyId,
    String roomId,
  ) async {
    final compressed = await compress(file, maxWidth: 1080);
    final ref = _storage.ref(
      'families/$familyId/chat/$roomId/${_uuid.v4()}.jpg',
    );
    return _upload(ref, compressed);
  }

  Future<String> uploadFamilyCover(File file, String familyId) async {
    final compressed = await compress(file, maxWidth: 1600);
    final ref = _storage.ref('families/$familyId/cover.jpg');
    return _upload(ref, compressed);
  }

  Future<String> _upload(Reference ref, File file) async {
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      _log.w('ລຶບຮູບບໍ່ສຳເລັດ: $e');
    }
  }
}
