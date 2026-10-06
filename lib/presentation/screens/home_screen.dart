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
import 'package:plants_app_ui/routing/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final Set<String> _favoriteIds = {};

  List<PlantModel> get _filteredPlants {
    final category = AppData.categories[_selectedCategoryIndex].name;
    return AppData.plants.where((plant) => plant.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildHeaderRow(),
                        _buildPromoBanner(),
                        _buildCategoryChips(),
                        _buildCollectionsHeader(),
                      ],
                    ),
                    Expanded(child: _buildPlantCards()),
                  ],
                ),
              ),
            ),
            _buildCartBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: .start,
      mainAxisAlignment: .spaceBetween,
      children: [
        SizedBox(
          width: NumberConstant.homeTitleWidth,
          child: Text.rich(
            TextSpan(
              text: StringConst.homeTitlePrefix,
              style: AppTextStyles.homeTitle,
              children: [
                TextSpan(text: StringConst.homeTitleHighlight, style: AppTextStyles.homeTitleBold,),
              ],
            ),
          ),
        ),
        _buildDrawerButton(),
      ],
    );
  }

  Widget _buildDrawerButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: .circular(NumberConstant.drawerButtonRadius),
        border: .all(color: AppColors.blackColor),
      ),
      padding: .symmetric(
        horizontal: NumberConstant.drawerButtonPaddingH,
        vertical: NumberConstant.drawerButtonPaddingV,
      ),
      child: SvgPicture.asset(AssetRes.icDrawer,),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.promoGrayColor,
        borderRadius: .circular(NumberConstant.promoBannerRadius),
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
              Text(AppData.promoOffer.title, style: AppTextStyles.promoTitle,),
              Text(AppData.promoOffer.dateRange, style: AppTextStyles.promoDate,),
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
                    fit: .contain,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        spacing: NumberConstant.contentSpacing,
        children: List.generate(
          AppData.categories.length,
          (index) {
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blackColor : AppColors.chipGrayColor,
                  borderRadius: .circular(NumberConstant.categoryChipRadius),
                ),
                padding: .symmetric(
                  horizontal: NumberConstant.categoryChipPaddingH,
                  vertical: NumberConstant.categoryChipPaddingV,
                ),
                child: Text(
                  AppData.categories[index].name,
                  style: AppTextStyles.chipLabel.copyWith(
                    color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                  ),
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
        Text(StringConst.plantCollections, style: AppTextStyles.sectionTitle,),
        Icon(Icons.arrow_forward, color: AppColors.blackColor,),
      ],
    );
  }

  Widget _buildPlantCards() {
    final plants = _filteredPlants;
    if (plants.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
      scrollDirection: .horizontal,
      padding: .only(bottom: NumberConstant.screenBottomPadding),
      itemCount: plants.length,
      separatorBuilder: (context, index) => const SizedBox(width: NumberConstant.plantCardGap),
      itemBuilder: (context, index) => _buildPlantCard(plant: plants[index]),
    );
  }

  Widget _buildPlantCard({required PlantModel plant}) {
    final isFavorite = _favoriteIds.contains(plant.id);
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
          Expanded(child: Image.asset(plant.image, fit: .cover,),),
          Text(plant.name, style: AppTextStyles.plantName, textAlign: .center,),
          Text(plant.description, style: AppTextStyles.plantDescription, textAlign: .center,),
          // const Spacer(),
          Row(
            mainAxisAlignment: .spaceBetween,
            spacing: 15,
            children: [
              Expanded(
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
                        child: SvgPicture.asset(AssetRes.icCart,),
                      ),
                      Text(StringConst.addToCart, style: AppTextStyles.addToCart,),
                    ],
                  ),
                ),
              ),
              _buildFavoriteButton(plantId: plant.id, isFavorite: isFavorite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton({required String plantId, required bool isFavorite}) {
    return GestureDetector(
      onTap: () => setState(() => isFavorite ? _favoriteIds.remove(plantId) : _favoriteIds.add(plantId)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackColor,
          shape: .circle,
        ),
        padding: .all(NumberConstant.favoriteButtonPadding),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: AppColors.whiteColor,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCartBar(BuildContext context) {
    final cartCount = AppData.cartItems.length;
    return GestureDetector(
      onTap: () => context.push(NamedRoutes.cart.routeName),
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
                      child: Text('$cartCount', style: AppTextStyles.cartBadgeCount,),
                    ),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(StringConst.cart, style: AppTextStyles.cartBarTitle,),
                        Text('$cartCount ${StringConst.items}', style: AppTextStyles.cartBarSubtitle,),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                _buildCartThumbs(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartThumbs() {
    final items = AppData.cartItems;
    return SizedBox(
      width: NumberConstant.cartThumbImageWidth +
          (NumberConstant.cartThumbPaddingH * 2) +
          ((items.length - 1) * NumberConstant.cartThumbOverlap),
      height: NumberConstant.cartThumbImageHeight + (NumberConstant.cartThumbPaddingV * 2),
      child: Stack(
        children: List.generate(
          items.length,
          (index) => Positioned(
            left: index * NumberConstant.cartThumbOverlap,
            child: _buildCircularPlantThumb(image: items[index].plant.image),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularPlantThumb({required String image}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardGrayColor,
        shape: .circle,
        border: .all(color: AppColors.whiteColor),
      ),
      padding: .symmetric(
        horizontal: NumberConstant.cartThumbPaddingH,
        vertical: NumberConstant.cartThumbPaddingV,
      ),
      child: Image.asset(
        image,
        height: NumberConstant.cartThumbImageHeight,
        width: NumberConstant.cartThumbImageWidth,
        fit: .contain,
      ),
    );
  }
}
