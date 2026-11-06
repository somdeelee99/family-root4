/// ຄ່າຄົງທີ່ ແລະ ໄລຍະຫ່າງທີ່ໃຊ້ໃນການຈັດຜັງໄມ້ຄອບຄົວ.
///
/// ຄວາມຕ່າງລະຫວ່າງ [spouseGap] (ນ້ອຍ) ກັບ [siblingGap] (ໃຫຍ່ກວ່າ)
/// ເຮັດໃຫ້ຄູ່ຜົວ–ເມຍຖືກມອງເຫັນວ່າຢູ່ຕິດກັນອັດຕະໂນມັດ.
class TreeLayoutConfig {
  const TreeLayoutConfig({
    this.spouseGap = 12,
    this.siblingGap = 36,
    this.groupGap = 64,
    this.generationGap = 74,
    this.padding = 60,
  });

  /// ຂະໜາດກາດສະມາຊິກ (ຕ້ອງກົງກັບ TreeNodeCard)
  static const double nodeWidth = 128;
  static const double nodeHeight = 150;

  /// ໄລຍະຫ່າງລະຫວ່າງຜົວ–ເມຍ (ໃຫ້ຕິດກັນ)
  final double spouseGap;

  /// ໄລຍະຫ່າງລະຫວ່າງລູກໃນກຸ່ມດຽວກັນ
  final double siblingGap;

  /// ໄລຍະຫ່າງລະຫວ່າງກຸ່ມລູກຂອງຄູ່ຕ່າງກັນ
  final double groupGap;

  /// ໄລຍະຫ່າງລະຫວ່າງລຸ້ນ
  final double generationGap;

  /// ຂອບຮອບ canvas
  final double padding;

  double get rowHeight => nodeHeight + generationGap;
}
