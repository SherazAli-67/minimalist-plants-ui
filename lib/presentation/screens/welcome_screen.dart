import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/core/app_textstyles.dart';
import 'package:plants_app_ui/core/asset_res.dart';
import 'package:plants_app_ui/routing/router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 900);
  static const _exitDuration = Duration(milliseconds: 280);
  static const _breathDuration = Duration(milliseconds: 2400);

  late final AnimationController _entranceController;
  late final AnimationController _breathController;
  late final AnimationController _exitController;
  late final AnimationController _pressController;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _imageFade;
  late final Animation<double> _imageScale;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _breathScale;
  late final Animation<double> _exitFade;
  late final Animation<double> _pressScale;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(vsync: this, duration: _entranceDuration,);
    _breathController = AnimationController(vsync: this, duration: _breathDuration,);
    _exitController = AnimationController(vsync: this, duration: _exitDuration,);
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),);

    _titleFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut),);
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero,).animate(CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),),);

    _imageFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.25, 0.7, curve: Curves.easeOut),);
    _imageScale = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),),);

    _buttonFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.55, 1.0, curve: Curves.easeOut),);
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero,).animate(CurvedAnimation(parent: _entranceController, curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),),);

    _breathScale = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),);
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn),);
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut),);

    _entranceController.forward().then((_) {
      if (mounted) _breathController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathController.dispose();
    _exitController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _onGoPressed() async {
    if (_isNavigating) return;
    _isNavigating = true;

    await _pressController.forward();
    await _pressController.reverse();
    _breathController.stop();
    await _exitController.forward();

    if (!mounted) return;
    context.go(NamedRoutes.home.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _exitFade,
        child: SafeArea(
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
                _buildGoButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _titleFade,
      child: SlideTransition(
        position: _titleSlide,
        child: Row(
          mainAxisAlignment: .center,
          children: [
            //width, height: welcomeTitleLineWidth
            Container(
              color: AppColors.blackColor,
              width: NumberConstant.welcomeTitleLineWidth,
              height: NumberConstant.welcomeTitleLineHeight,
            ),
            SizedBox(
              width: NumberConstant.welcomeTitleWidth,
              //welcomeTitle
              child: Text(
                StringConst.welcomeTitle,
                textAlign: .center,
                style: AppTextStyles.welcomeTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    return FadeTransition(
      opacity: _imageFade,
      child: ScaleTransition(
        scale: _imageScale,
        child: ScaleTransition(
            scale: _breathScale,
            //welcomePageImage, width:welcomePlantSize, fit: contain
            child: Image.asset(AssetRes.welcomePageImg, width: NumberConstant.welcomePlantSize, fit: .contain,)
        ),
      ),
    );
  }

  Widget _buildGoButton() {
    return FadeTransition(
      opacity: _buttonFade,
      child: SlideTransition(
        position: _buttonSlide,
        child: ScaleTransition(
          scale: _pressScale,
          child: GestureDetector(
            onTap: _onGoPressed,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                shape: .circle,
              ),
              padding: .all(NumberConstant.goButtonPadding),
              //StringConst.go, goButton
              child: Text(StringConst.go, style: AppTextStyles.goButton,),
            ),
          ),
        ),
      ),
    );
  }
}