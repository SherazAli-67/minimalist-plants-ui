import 'package:flutter/material.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/core/app_colors.dart';

class CircularPlantThumb extends StatelessWidget {
  final String image;
  final double imageHeight;
  final double imageWidth;
  final double paddingH;
  final double paddingV;

  const CircularPlantThumb({
    super.key,
    required this.image,
    this.imageHeight = NumberConstant.cartThumbImageHeight,
    this.imageWidth = NumberConstant.cartThumbImageWidth,
    this.paddingH = NumberConstant.cartThumbPaddingH,
    this.paddingV = NumberConstant.cartThumbPaddingV,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardGrayColor,
        shape: .circle,
        border: .all(color: AppColors.whiteColor),
      ),
      padding: .symmetric(horizontal: paddingH, vertical: paddingV),
      child: Image.asset(image, height: imageHeight, width: imageWidth, fit: .contain,),
    );
  }
}
