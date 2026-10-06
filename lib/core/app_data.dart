import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/asset_res.dart';
import 'package:plants_app_ui/core/models/cart_item_model.dart';
import 'package:plants_app_ui/core/models/category_model.dart';
import 'package:plants_app_ui/core/models/plant_model.dart';
import 'package:plants_app_ui/core/models/promo_offer_model.dart';

class AppData {
  static const categories = [
    CategoryModel(name: 'Plants'),
    CategoryModel(name: 'Flowers'),
    CategoryModel(name: 'Cacti'),
    CategoryModel(name: 'Herbs'),
    CategoryModel(name: 'Bonsai'),
  ];

  static const pottedHead = PlantModel(
    id: 'potted_head',
    name: 'The Potted Head',
    description: 'Perfect for beginners or anyone looking for an easy-to-care-for plant',
    image: AssetRes.pottedHeadPlantImg,
    price: 50,
    category: 'Plants',
  );

  static const ledgerBlock = PlantModel(
    id: 'ledger_block',
    name: 'Ledger Block',
    description: 'Perfect for beginners or anyone looking for an easy-to-care-for plant',
    image: AssetRes.ledgerBlockPlantImg,
    price: 42.5,
    category: 'Plants',
  );

  static const friendlyFern = PlantModel(
    id: 'friendly_fern',
    name: 'The Friendly Fern',
    description: 'Perfect for beginners or anyone looking for an easy-to-care-for plant',
    image: AssetRes.friendlyFernImg,
    price: 60,
    category: 'Plants',
  );

  static const miniCacti = PlantModel(
    id: 'mini_cacti',
    name: 'Mini Cacti',
    description: 'Perfect for beginners or anyone looking for an easy-to-care-for plant',
    image: AssetRes.miniCactiImg,
    price: 25,
    category: 'Cacti',
  );

  static const plants = [
    pottedHead,
    ledgerBlock,
    friendlyFern,
    miniCacti,
  ];

  static const promoOffer = PromoOfferModel(
    title: StringConst.promoOff,
    dateRange: StringConst.promoDate,
    imagePaths: [
      AssetRes.friendlyFernImg,
      AssetRes.ledgerBlockPlantImg,
    ],
  );

  static const cartItems = [
    CartItemModel(plant: pottedHead, quantity: 1),
    CartItemModel(plant: ledgerBlock, quantity: 2),
    CartItemModel(plant: friendlyFern, quantity: 3),
    CartItemModel(plant: miniCacti, quantity: 1),
  ];

  static const deliveryAmount = 25.50;

  static double get cartTotal =>
      cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice) + deliveryAmount;
}
