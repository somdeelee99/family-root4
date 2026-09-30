class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w\.\-\+]+@[\w\-]+(\.[\w\-]+)+$');
  static final RegExp _phone = RegExp(r'^[0-9\+\-\s]{6,20}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'ກະລຸນາປ້ອນອີແມວ';
    if (!_email.hasMatch(value.trim())) return 'ຮູບແບບອີແມວບໍ່ຖືກຕ້ອງ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
    if (value.length < 6) return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
    return null;
  }

  static String? required(String? value, {String field = 'ຂໍ້ມູນ'}) {
    if (value == null || value.trim().isEmpty) return 'ກະລຸນາປ້ອນ$field';
    return null;
  }

  static String? phone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'ກະລຸນາປ້ອນເບີໂທ' : null;
    }
    if (!_phone.hasMatch(value.trim())) return 'ເບີໂທບໍ່ຖືກຕ້ອງ';
    return null;
  }

  /// ແປງເບີໂທລາວ (020xxxxxxxx) ເປັນຮູບແບບສາກົນ ສຳລັບ WhatsApp
  static String toWhatsApp(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '856${digits.substring(1)}';
    if (!digits.startsWith('856') && digits.length <= 10) digits = '856$digits';
    return digits;
  }
}
