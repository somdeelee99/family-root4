import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// ຕິດຕາມສະຖານະການເຊື່ອມຕໍ່ອິນເຕີເນັດ
/// Firestore ຈະເຮັດວຽກ offline-first ຢູ່ແລ້ວ, ຊັ້ນນີ້ໃຊ້ສະແດງແຈ້ງເຕືອນໃຫ້ຜູ້ໃຊ້
class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final RxBool isOnline = true.obs;

  Future<ConnectivityService> init() async {
    final result = await _connectivity.checkConnectivity();
    isOnline.value = _hasConnection(result);
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (online != isOnline.value) {
        _log.i('ສະຖານະເນັດ: ${online ? 'ອອນລາຍ' : 'ອອບລາຍ'}');
      }
      isOnline.value = online;
    });
    return this;
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
