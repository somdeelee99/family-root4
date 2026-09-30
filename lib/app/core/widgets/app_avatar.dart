import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/models/enums.dart';
import '../constants/app_colors.dart';

/// ຮູບໂປຣໄຟລ໌ແບບມືອາຊີບ
/// - ຖ້າບໍ່ມີຮູບ ຈະສະແດງຕົວອັກສອນທຳອິດ ພ້ອມສີຕາມເພດ
/// - ມີວົງແຫວນສະຖານະ (ມີຊີວິດ / ເສຍຊີວິດ)
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.size = 52,
    this.gender,
    this.status,
    this.showStatusBadge = false,
    this.isAdmin = false,
    this.borderRadius,
    this.onTap,
  });

  final String? imageUrl;
  final String name;
  final double size;
  final Gender? gender;
  final MemberStatus? status;
  final bool showStatusBadge;
  final bool isAdmin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  Color get _fallbackColor => AppColors.forGender(gender?.value);

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2.6);

    Widget avatar = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: _fallbackColor.withValues(alpha: 0.12),
        image: (imageUrl != null && imageUrl!.isNotEmpty) ? null : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: size.w,
                height: size.w,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _initialsBox(),
              )
            : _initialsBox(),
      ),
    );

    if (showStatusBadge && status != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: status == MemberStatus.deceased
                    ? AppColors.deceased
                    : AppColors.alive,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: status == MemberStatus.deceased
                  ? Icon(Icons.close_rounded,
                      size: size * 0.16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      );
    }

    if (isAdmin) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: EdgeInsets.all(size * 0.04),
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_rounded,
                  size: size * 0.22, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return avatar;
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: avatar,
    );
  }

  Widget _initialsBox() => Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _fallbackColor.withValues(alpha: 0.85),
              _fallbackColor.withValues(alpha: 0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.36,
          ),
        ),
      );

  Widget _placeholder() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
            color: Colors.grey.shade300, width: size.w, height: size.w),
      );
}
