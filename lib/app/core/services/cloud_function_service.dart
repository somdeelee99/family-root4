import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// ບໍລິການເອີ້ນໃຊ້ Cloud Functions ຝັ່ງເຊີບເວີ
/// ໃຊ້ສຳລັບວຽກທີ່ຕ້ອງການຄວາມປອດໄພສູງ ເຊັ່ນ ການສ້າງບັນຊີ member ໂດຍ admin
class CloudFunctionService {
  CloudFunctionService._internal();
  static final CloudFunctionService instance = CloudFunctionService._internal();

  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// ສ້າງບັນຊີ member (ເຮັດຢູ່ເຊີບເວີ ເພື່ອບໍ່ໃຫ້ admin ອອກຈາກລະບົບ)
  /// ຖ້າ Cloud Function ຍັງບໍ່ຖືກ deploy ຈະສົ່ງຄືນ null ແລະ ແອັບຈະໃຊ້ວິທີສຳຮອງ (secondary auth)
  Future<String?> createMemberAccount({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String familyId,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'createMemberAccount',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final result = await callable.call<Map<String, dynamic>>({
        'email': email.trim(),
        'password': password,
        'displayName': displayName,
        'role': role,
        'familyId': familyId,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (whatsapp != null && whatsapp.isNotEmpty) 'whatsapp': whatsapp,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        if (gender != null) 'gender': gender,
      });
      return result.data['uid'] as String?;
    } on FirebaseFunctionsException catch (e) {
      _log.w('Cloud Function ບໍ່ສຳເລັດ (${e.code}) - ໃຊ້ວິທີສຳຮອງ');
      if (kDebugMode) _log.d(e.message);
      return null;
    } catch (e) {
      _log.w('Cloud Function ບໍ່ສາມາດເຂົ້າເຖິງໄດ້ - ໃຊ້ວິທີສຳຮອງ: $e');
      return null;
    }
  }

  /// ລຶບບັນຊີຜູ້ໃຊ້ອອກຈາກ Firebase Auth ຢ່າງສົມບູນ
  Future<bool> deleteUserAccount(String uid) async {
    try {
      final callable = _functions.httpsCallable('deleteUserAccount');
      await callable.call<void>({'uid': uid});
      return true;
    } catch (e) {
      _log.w('ລຶບບັນຊີດ້ວຍ Cloud Function ບໍ່ສຳເລັດ: $e');
      return false;
    }
  }
}
