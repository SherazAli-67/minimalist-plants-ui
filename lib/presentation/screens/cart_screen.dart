import 'package:flutter/material.dart';
import 'package:plants_app_ui/constants/number_constant.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/core/app_textstyles.dart';
import 'package:plants_app_ui/core/models/cart_item_model.dart';
import 'package:plants_app_ui/providers/cart_provider.dart';
import 'package:plants_app_ui/presentation/widgets/circular_plant_thumb.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 700);

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
    final start = (step * 0.12).clamp(0.0, 0.8);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _entranceSlide(int step) {
    final start = (step * 0.12).clamp(0.0, 0.8);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.1),
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
    final cartProvider = context.watch<CartProvider>();
    final hasItems = cartProvider.hasItems;

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
              _entranceBlock(step: 0, child: _CartHeader(cartCount: cartProvider.itemCount)),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: hasItems
                      ? _CartList(
                          key: const ValueKey('cart_list'),
                          items: cartProvider.items,
                        )
                      : Center(
                          key: const ValueKey('cart_empty'),
                          child: Text(
                            StringConst.emptyCart,
                            style: AppTextStyles.sectionTitle,
                          ),
                        ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: hasItems
                    ? _CartSummary(
                        key: const ValueKey('cart_summary'),
                        cartProvider: cartProvider,
                      )
                    : const SizedBox(key: ValueKey('cart_summary_empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(StringConst.cart, style: AppTextStyles.cartTitle),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cartBadgeGrayColor,
            shape: .circle,
          ),
          padding: .all(NumberConstant.cartCountBadgePadding),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$cartCount',
              key: ValueKey<int>(cartCount),
              style: AppTextStyles.cartCountBadge,
            ),
          ),
        ),
      ],
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({super.key, required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.dividerColor,
        height: NumberConstant.cartItemGap,
      ),
      itemBuilder: (context, index) => _CartItemRow(
        key: ValueKey(items[index].plant.id),
        item: items[index],
        entranceIndex: index,
      ),
    );
  }
}

class _CartItemRow extends StatefulWidget {
  const _CartItemRow({
    super.key,
    required this.item,
    required this.entranceIndex,
  });

  final CartItemModel item;
  final int entranceIndex;

  @override
  State<_CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<_CartItemRow> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _exitController;
  late final AnimationController _minusPressController;
  late final AnimationController _plusPressController;

  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _exitFade;
  late final Animation<Offset> _exitSlide;
  late final Animation<double> _minusScale;
  late final Animation<double> _plusScale;

  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _minusPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _plusPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.08, 0),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
    _minusScale = Tween<double>(begin: 1, end: 0.88).animate(
      CurvedAnimation(parent: _minusPressController, curve: Curves.easeOut),
    );
    _plusScale = Tween<double>(begin: 1, end: 0.88).animate(
      CurvedAnimation(parent: _plusPressController, curve: Curves.easeOut),
    );

    Future<void>.delayed(Duration(milliseconds: widget.entranceIndex * 70), () {
      if (mounted && !_isRemoving) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    _minusPressController.dispose();
    _plusPressController.dispose();
    super.dispose();
  }

  Future<void> _onDecrement() async {
    if (_isRemoving) return;

    await _minusPressController.forward();
    await _minusPressController.reverse();

    if (!mounted) return;

    if (widget.item.quantity <= 1) {
      setState(() => _isRemoving = true);
      await _exitController.forward();
      if (!mounted) return;
      context.read<CartProvider>().decrementQuantity(widget.item.plant.id);
    } else {
      context.read<CartProvider>().decrementQuantity(widget.item.plant.id);
    }
  }

  Future<void> _onIncrement() async {
    if (_isRemoving) return;

    await _plusPressController.forward();
    await _plusPressController.reverse();

    if (!mounted) return;
    context.read<CartProvider>().incrementQuantity(widget.item.plant.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final quantityLabel = item.quantity == 1
        ? '${item.quantity} ${StringConst.piece}'
        : '${item.quantity} ${StringConst.pieces}';

    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _exitController]),
      builder: (context, child) {
        final fade = _isRemoving ? _exitFade.value : _entranceFade.value;
        final slide = _isRemoving ? _exitSlide.value : _entranceSlide.value;
        return FadeTransition(
          opacity: AlwaysStoppedAnimation(fade),
          child: SlideTransition(
            position: AlwaysStoppedAnimation(slide),
            child: child,
          ),
        );
      },
      child: Row(
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
                    Text(item.plant.name, style: AppTextStyles.cartItemName),
                    Row(
                      spacing: 8,
                      children: [
                        ScaleTransition(
                          scale: _minusScale,
                          child: GestureDetector(
                            onTap: _onDecrement,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardGrayColor,
                                shape: .circle,
                              ),
                              padding: .all(4),
                              child: Icon(
                                Icons.remove,
                                color: AppColors.secondaryTextColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.35),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            quantityLabel,
                            key: ValueKey<String>(quantityLabel),
                            style: AppTextStyles.cartItemQuantity,
                          ),
                        ),
                        ScaleTransition(
                          scale: _plusScale,
                          child: GestureDetector(
                            onTap: _onIncrement,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardGrayColor,
                                shape: .circle,
                              ),
                              padding: .all(4),
                              child: Icon(
                                Icons.add,
                                color: AppColors.secondaryTextColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          _AnimatedPriceChip(price: item.totalPrice),
        ],
      ),
    );
  }
}

class _AnimatedPriceChip extends StatelessWidget {
  const _AnimatedPriceChip({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: .circular(NumberConstant.cartPriceChipRadius),
      ),
      padding: .all(NumberConstant.cartPriceChipPadding),
      child: _AnimatedCurrencyText(
        value: price,
        style: AppTextStyles.cartItemPrice,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({super.key, required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: NumberConstant.summaryTopGap,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(StringConst.deliveryAmount, style: AppTextStyles.deliveryLabel),
            Text(
              '\$${cartProvider.deliveryAmount.toStringAsFixed(2)}',
              style: AppTextStyles.deliveryAmount,
            ),
          ],
        ),
        Divider(color: AppColors.dividerColor, height: 1),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(StringConst.totalAmount, style: AppTextStyles.totalLabel),
            _AnimatedTotalAmount(total: cartProvider.cartTotal),
          ],
        ),
        const _PaymentButton(),
      ],
    );
  }
}

class _AnimatedTotalAmount extends StatelessWidget {
  const _AnimatedTotalAmount({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return _AnimatedCurrencyText(
      value: total,
      style: AppTextStyles.totalAmount,
    );
  }
}

class _AnimatedCurrencyText extends StatefulWidget {
  const _AnimatedCurrencyText({
    required this.value,
    required this.style,
  });

  final double value;
  final TextStyle style;

  @override
  State<_AnimatedCurrencyText> createState() => _AnimatedCurrencyTextState();
}

class _AnimatedCurrencyTextState extends State<_AnimatedCurrencyText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = AlwaysStoppedAnimation(_displayValue);
    _controller.addListener(() {
      setState(() => _displayValue = _animation.value);
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedCurrencyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;

    _animation = Tween<double>(
      begin: oldWidget.value,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${_displayValue.toStringAsFixed(2)}',
      style: widget.style,
    );
  }
}

class _PaymentButton extends StatefulWidget {
  const _PaymentButton();

  @override
  State<_PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<_PaymentButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _pressController.forward();
    await _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
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
              Text(StringConst.makePayment, style: AppTextStyles.makePayment),
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
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.whiteColor.withValues(alpha: 0.4),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.whiteColor.withValues(alpha: 0.7),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.whiteColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
