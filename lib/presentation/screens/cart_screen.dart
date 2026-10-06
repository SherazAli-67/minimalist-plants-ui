import 'package:flutter/material.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/core/app_data.dart';
import 'package:plants_app_ui/core/app_textstyles.dart';
import 'package:plants_app_ui/core/models/cart_item_model.dart';
import 'package:plants_app_ui/presentation/widgets/circular_plant_thumb.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .fromLTRB(
            NumberConstant.horizontalPadding,
            NumberConstant.cartHeaderTop,
            NumberConstant.horizontalPadding,
            NumberConstant.screenBottomPadding,
          ),
          child: Column(
            spacing: NumberConstant.sectionSpacing,
            children: [
              _buildHeader(),
              Expanded(child: _buildCartList()),
              _buildSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cartCount = AppData.cartItems.length;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(StringConst.cart, style: AppTextStyles.cartTitle,),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cartBadgeGrayColor,
            shape: .circle,
          ),
          padding: .all(NumberConstant.cartCountBadgePadding),
          child: Text('$cartCount', style: AppTextStyles.cartCountBadge,),
        ),
      ],
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      itemCount: AppData.cartItems.length,
      separatorBuilder: (context, index) => Divider(color: AppColors.dividerColor, height: NumberConstant.cartItemGap,),
      itemBuilder: (context, index) => _buildCartItem(item: AppData.cartItems[index]),
    );
  }

  Widget _buildCartItem({required CartItemModel item}) {
    final quantityLabel = item.quantity == 1
        ? '${item.quantity} ${StringConst.piece}'
        : '${item.quantity} ${StringConst.pieces}';
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: NumberConstant.contentSpacing,
            children: [
              CircularPlantThumb(
                image: item.plant.image,
                imageHeight: NumberConstant.cartItemThumbImageHeight,
                imageWidth: NumberConstant.cartItemThumbImageWidth,
                paddingH: NumberConstant.cartItemThumbPaddingH,
                paddingV: NumberConstant.cartItemThumbPaddingV,
              ),
              Column(
                crossAxisAlignment: .start,
                spacing: NumberConstant.contentSpacing,
                children: [
                  Text(item.plant.name, style: AppTextStyles.cartItemName,),
                  Text(quantityLabel, style: AppTextStyles.cartItemQuantity,),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: .circular(NumberConstant.cartPriceChipRadius),
          ),
          padding: .all(NumberConstant.cartPriceChipPadding),
          child: Text('\$${item.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.cartItemPrice,),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      spacing: NumberConstant.summaryTopGap,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(StringConst.deliveryAmount, style: AppTextStyles.deliveryLabel,),
            Text('\$${AppData.deliveryAmount.toStringAsFixed(2)}', style: AppTextStyles.deliveryAmount,),
          ],
        ),
        Divider(color: AppColors.dividerColor, height: 1,),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(StringConst.totalAmount, style: AppTextStyles.totalLabel,),
            Text('\$${AppData.cartTotal.toStringAsFixed(2)}', style: AppTextStyles.totalAmount,),
          ],
        ),
        _buildPaymentButton(),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: .circular(NumberConstant.paymentButtonRadius),
        border: .all(color: AppColors.blackColor),
      ),
      padding: .symmetric(
        horizontal: NumberConstant.paymentButtonPaddingH,
        vertical: NumberConstant.paymentButtonPaddingV,
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(StringConst.makePayment, style: AppTextStyles.makePayment,),
          Container(
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              borderRadius: .circular(NumberConstant.paymentActionRadius),
            ),
            padding: .symmetric(
              horizontal: NumberConstant.paymentActionPaddingH,
              vertical: NumberConstant.paymentActionPaddingV,
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Icon(Icons.chevron_right, color: AppColors.whiteColor.withValues(alpha: 0.4),),
                Icon(Icons.chevron_right, color: AppColors.whiteColor.withValues(alpha: 0.7),),
                Icon(Icons.chevron_right, color: AppColors.whiteColor,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
