import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/core/app_data.dart';
import 'package:plants_app_ui/core/app_textstyles.dart';
import 'package:plants_app_ui/core/asset_res.dart';
import 'package:plants_app_ui/core/models/plant_model.dart';
import 'package:plants_app_ui/providers/cart_provider.dart';
import 'package:plants_app_ui/presentation/widgets/circular_plant_thumb.dart';
import 'package:plants_app_ui/routing/router.dart';
import 'package:provider/provider.dart';

import '../../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 850);

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Animation<double> _entranceFade(int step) {
    final start = (step * 0.11).clamp(0.0, 0.85);
    final end = (start + 0.38).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _entranceSlide(int step) {
    final start = (step * 0.11).clamp(0.0, 0.85);
    final end = (start + 0.38).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _entranceBlock({required int step, required Widget child}) {
    return FadeTransition(
      opacity: _entranceFade(step),
      child: SlideTransition(
        position: _entranceSlide(step),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = context.watch<CartProvider>().hasItems;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: .fromLTRB(
                  NumberConstant.horizontalPadding,
                  NumberConstant.homeHeaderTop,
                  NumberConstant.horizontalPadding,
                  0,
                ),
                child: Column(
                  spacing: NumberConstant.contentSpacing,
                  children: [
                    Column(
                      spacing: NumberConstant.sectionSpacing,
                      children: [
                        _entranceBlock(step: 0, child: _buildHeaderRow()),
                        _entranceBlock(step: 1, child: _buildPromoBanner()),
                        _entranceBlock(step: 2, child: _buildCategoryChips(context)),
                        _entranceBlock(step: 3, child: _buildCollectionsHeader()),
                      ],
                    ),
                    Expanded(
                      child: _entranceBlock(
                        step: 4,
                        child: _buildPlantCards(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return ClipRect(
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.35),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );
              },
              child: hasItems
                  ? _HomeCartBar(
                      key: const ValueKey('home_cart_bar'),
                      onTap: () => context.push(NamedRoutes.cart.routeName),
                    )
                  : const SizedBox(
                      key: ValueKey('home_cart_empty'),
                      width: double.infinity,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: .center,
      mainAxisAlignment: .spaceBetween,
      children: [
        SizedBox(
          width: NumberConstant.homeTitleWidth,
          child: Text.rich(
            TextSpan(
              text: StringConst.homeTitlePrefix,
              style: AppTextStyles.homeTitle,
              children: [
                TextSpan(
                  text: StringConst.homeTitleHighlight,
                  style: AppTextStyles.homeTitleBold,
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: .circular(NumberConstant.drawerButtonRadius),
            border: .all(color: AppColors.blackColor),
          ),
          padding: .symmetric(
            horizontal: NumberConstant.drawerButtonPaddingH,
            vertical: NumberConstant.drawerButtonPaddingV,
          ),
          child: SvgPicture.asset(AssetRes.icDrawer),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: .circular(NumberConstant.promoBannerRadius),
        color: AppColors.promoGrayColor,
      ),
      padding: .symmetric(
        horizontal: NumberConstant.promoBannerPaddingH,
        vertical: NumberConstant.promoBannerPaddingV,
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: .start,
            spacing: NumberConstant.contentSpacing,
            children: [
              Text(AppData.promoOffer.title, style: AppTextStyles.promoTitle),
              Text(AppData.promoOffer.dateRange, style: AppTextStyles.promoDate),
            ],
          ),
          Row(
            spacing: NumberConstant.contentSpacing,
            children: AppData.promoOffer.imagePaths
                .map(
                  (image) => Image.asset(
                    image,
                    width: NumberConstant.promoImageWidth,
                    height: NumberConstant.promoImageHeight,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        spacing: NumberConstant.contentSpacing,
        children: List.generate(
          AppData.categories.length,
          (index) {
            final isSelected = homeProvider.selectedCategoryIndex == index;
            final category = AppData.categories[index].name;
            return GestureDetector(
              onTap: () => context.read<HomeProvider>().selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blackColor : AppColors.chipGrayColor,
                  borderRadius: .circular(NumberConstant.categoryChipRadius),
                ),
                padding: .symmetric(
                  horizontal: NumberConstant.categoryChipPaddingH,
                  vertical: NumberConstant.categoryChipPaddingV,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: AppTextStyles.chipLabel.copyWith(
                    color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                  child: Text(category),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollectionsHeader() {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(StringConst.plantCollections, style: AppTextStyles.sectionTitle),
        Icon(Icons.arrow_forward, color: AppColors.blackColor),
      ],
    );
  }

  Widget _buildPlantCards(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final plants = homeProvider.filteredPlants;
    if (plants.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: ListView.separated(
        key: ValueKey(homeProvider.selectedCategoryIndex),
        scrollDirection: .horizontal,
        padding: .only(bottom: NumberConstant.screenBottomPadding),
        itemCount: plants.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: NumberConstant.plantCardGap),
        itemBuilder: (context, index) => _PlantCardEntrance(
          index: index,
          child: _PlantCard(plant: plants[index]),
        ),
      ),
    );
  }
}

class _PlantCardEntrance extends StatefulWidget {
  const _PlantCardEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_PlantCardEntrance> createState() => _PlantCardEntranceState();
}

class _PlantCardEntranceState extends State<_PlantCardEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future<void>.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

  final PlantModel plant;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<HomeProvider>().isFavorite(plant.id);
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.cardGrayColor,
        borderRadius: .circular(NumberConstant.plantCardRadius),
      ),
      padding: .all(NumberConstant.plantCardPadding),
      child: Column(
        spacing: NumberConstant.contentSpacing,
        children: [
          Expanded(child: Image.asset(plant.image, fit: .contain)),
          Text(plant.name, style: AppTextStyles.plantName, textAlign: .center),
          Text(
            plant.description,
            style: AppTextStyles.plantDescription,
            textAlign: .center,
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            spacing: 15,
            children: [
              Expanded(
                child: _AddToCartButton(
                  onPressed: () => context.read<CartProvider>().addToCart(plant),
                ),
              ),
              _FavoriteButton(
                isFavorite: isFavorite,
                onPressed: () => context.read<HomeProvider>().toggleFavorite(plant.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _pressController.forward();
    await _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: .circular(NumberConstant.addToCartRadius),
          ),
          padding: .fromLTRB(8, 5, 15, 5),
          child: Row(
            spacing: NumberConstant.contentSpacing,
            mainAxisSize: .min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: .circle,
                ),
                padding: .all(NumberConstant.addToCartIconPadding),
                child: SvgPicture.asset(AssetRes.icCart),
              ),
              Text(StringConst.addToCart, style: AppTextStyles.addToCart),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1, end: 0.88).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _tapController.forward();
    await _tapController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _tapScale,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            shape: .circle,
          ),
          padding: .all(NumberConstant.favoriteButtonPadding),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isFavorite),
              color: AppColors.whiteColor,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCartBar extends StatelessWidget {
  const _HomeCartBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartCount = cartProvider.itemCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.whiteColor,
        padding: .fromLTRB(
          NumberConstant.horizontalPadding,
          NumberConstant.cartBarTopPadding,
          NumberConstant.horizontalPadding,
          NumberConstant.screenBottomPadding,
        ),
        child: Column(
          spacing: NumberConstant.sectionSpacing,
          mainAxisSize: .min,
          children: [
            Container(
              width: NumberConstant.cartBarHandleWidth,
              height: NumberConstant.cartBarHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: .circular(NumberConstant.cartBarHandleRadius),
              ),
            ),
            Row(
              children: [
                Row(
                  spacing: NumberConstant.contentSpacing,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        shape: .circle,
                      ),
                      padding: .all(NumberConstant.cartBadgePadding),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$cartCount',
                          key: ValueKey<int>(cartCount),
                          style: AppTextStyles.cartBadgeCount,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(StringConst.cart, style: AppTextStyles.cartBarTitle),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '$cartCount ${StringConst.items}',
                            key: ValueKey<String>('items_$cartCount'),
                            style: AppTextStyles.cartBarSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                _CartThumbsStack(cartProvider: cartProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartThumbsStack extends StatelessWidget {
  const _CartThumbsStack({required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    final items = cartProvider.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: NumberConstant.cartThumbImageWidth +
          (NumberConstant.cartThumbPaddingH * 2) +
          ((items.length - 1) * NumberConstant.cartThumbOverlap),
      height: NumberConstant.cartThumbImageHeight + (NumberConstant.cartThumbPaddingV * 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          items.length,
          (index) => Positioned(
            left: index * NumberConstant.cartThumbOverlap,
            child: _CartThumbEntrance(
              key: ValueKey(items[index].plant.id),
              child: CircularPlantThumb(image: items[index].plant.image),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartThumbEntrance extends StatefulWidget {
  const _CartThumbEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<_CartThumbEntrance> createState() => _CartThumbEntranceState();
}

class _CartThumbEntranceState extends State<_CartThumbEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
