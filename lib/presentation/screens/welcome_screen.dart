import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/core/app_textstyles.dart';
import 'package:plants_app_ui/core/asset_res.dart';
import 'package:plants_app_ui/routing/router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .fromLTRB(
            NumberConstant.horizontalPadding,
            NumberConstant.welcomeTitleTop,
            NumberConstant.horizontalPadding,
            NumberConstant.welcomeBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              Align(alignment: .centerLeft, child: _buildTitle()),
              Expanded(child: Center(child: _buildPlantImage())),
              _buildGoButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Container(
          width: NumberConstant.welcomeTitleLineWidth,
          height: NumberConstant.welcomeTitleLineHeight,
          color: AppColors.blackColor,
        ),
        SizedBox(
          width: NumberConstant.welcomeTitleWidth,
          child: Text(StringConst.welcomeTitle, textAlign: .center, style: AppTextStyles.welcomeTitle,),
        ),
      ],
    );
  }

  Widget _buildPlantImage() {
    return Image.asset(
      AssetRes.welcomePageImg,
      width: NumberConstant.welcomePlantSize,
      height: NumberConstant.welcomePlantSize,
      fit: .contain,
    );
  }

  Widget _buildGoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(NamedRoutes.home.routeName),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackColor,
          shape: .circle,
        ),
        padding: .all(NumberConstant.goButtonPadding),
        child: Text(StringConst.go, style: AppTextStyles.goButton,),
      ),
    );
  }
}
