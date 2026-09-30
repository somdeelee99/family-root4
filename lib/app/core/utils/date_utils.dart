import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat displayDate = DateFormat('dd/MM/yyyy');
  static final DateFormat displayDateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat timeOnly = DateFormat('HH:mm');
  static final DateFormat monthYear = DateFormat('MM/yyyy');

  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String format(DateTime? date) =>
      date == null ? '-' : displayDate.format(date);

  /// ຄຳນວນອາຍຸ (ປີ)
  static int age(DateTime? birthDate, {DateTime? deathDate}) {
    if (birthDate == null) return 0;
    final end = deathDate ?? DateTime.now();
    int years = end.year - birthDate.year;
    final hasHadBirthday = (end.month > birthDate.month) ||
        (end.month == birthDate.month && end.day >= birthDate.day);
    if (!hasHadBirthday) years--;
    return years < 0 ? 0 : years;
  }

  static bool isUnder18(DateTime? birthDate) {
    if (birthDate == null) return false;
    return age(birthDate) < 18;
  }

  /// ອາຍຸແບບອ່ານງ່າຍ: 32 ປີ 4 ເດືອນ
  static String ageLabel(DateTime? birthDate, {DateTime? deathDate}) {
    if (birthDate == null) return '-';
    final years = age(birthDate, deathDate: deathDate);
    final end = deathDate ?? DateTime.now();
    int months = end.month - birthDate.month;
    if (end.day < birthDate.day) months--;
    if (months < 0) months += 12;
    return '$years ປີ $months ເດືອນ';
  }

  /// ເວລາແບບສັ້ນສຳລັບລາຍການແຊັດ
  static String chatStamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return timeOnly.format(date);
    if (diff == 1) return 'ມື້ວານນີ້';
    if (diff < 7) return '${diff} ວັນກ່ອນ';
    return displayDate.format(date);
  }

  static String relative(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'ດຽວນີ້';
    if (diff.inMinutes < 60) return '${diff.inMinutes} ນາທີກ່ອນ';
    if (diff.inHours < 24) return '${diff.inHours} ຊົ່ວໂມງກ່ອນ';
    if (diff.inDays < 30) return '${diff.inDays} ວັນກ່ອນ';
    return displayDate.format(date);
  }
}
