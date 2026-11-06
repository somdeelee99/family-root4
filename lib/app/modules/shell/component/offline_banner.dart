import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// ແຈ້ງເຕືອນເມື່ອເຄື່ອງອອບລາຍ
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 15),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'ທ່ານກຳລັງໃຊ້ງານແບບອອບລາຍ - ຂໍ້ມູນຈະຊິ້ງເມື່ອມີເນັດ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
