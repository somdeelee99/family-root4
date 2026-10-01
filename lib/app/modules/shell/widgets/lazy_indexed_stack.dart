import 'package:flutter/material.dart';

/// ຄ້າຍຄື [IndexedStack] ແຕ່ຈະ build ສະເພາະໜ້າທີ່ເຄີຍເປີດແລ້ວ
///
/// ປະໂຫຍດ:
/// - ບໍ່ build ທັງ 5 ໜ້າພ້ອມກັນຕອນເປີດແອັບ (ປະຢັດເວລາ ແລະ ຫນ່ວຍຄວາມຈຳ)
/// - ສະຖານະຂອງໜ້າທີ່ເຄີຍເປີດ (scroll, ຄຳຄົ້ນຫາ) ຍັງຄົງຢູ່
/// - ຫຼຸດໂອກາດ widget ຊ້ຳກັນ (ເຊັ່ນ Hero tag ຊ້ຳ) ລະຫວ່າງໜ້າ
///
/// ໝາຍເຫດ: ເມື່ອໜ້າໃດຖືກເປີດແລ້ວ ມັນຈະຄົງຢູ່ໃນຕົ້ນໄມ້ຕໍ່ໄປ
/// ສະນັ້ນ widget ທີ່ໃຊ້ tag ອັດຕະໂນມັດ (FloatingActionButton, Hero)
/// ຍັງຄວນຕັ້ງ tag ໃຫ້ບໍ່ຊ້ຳກັນຢູ່ດີ
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.sizing = StackFit.loose,
    this.alignment = AlignmentDirectional.topStart,
  });

  final int index;
  final List<Widget> children;
  final StackFit sizing;
  final AlignmentGeometry alignment;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late final Set<int> _loaded;

  @override
  void initState() {
    super.initState();
    _loaded = {widget.index};
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_loaded.contains(widget.index) && widget.index < widget.children.length) {
      _loaded.add(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      sizing: widget.sizing,
      alignment: widget.alignment,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_loaded.contains(i))
            widget.children[i]
          else
            const SizedBox.shrink(),
      ],
    );
  }
}
