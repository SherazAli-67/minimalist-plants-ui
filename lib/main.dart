import 'package:flutter/material.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/core/app_colors.dart';
import 'package:plants_app_ui/providers/cart_provider.dart';
import 'package:plants_app_ui/providers/home_provider.dart';
import 'package:plants_app_ui/routing/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        title: StringConst.appTitle,
        theme: ThemeData(
          brightness: .light,
          fontFamily: StringConst.appFontFamily,
          scaffoldBackgroundColor: AppColors.whiteColor,
        ),
        routerConfig: router,
        builder: (ctx, child) => child!,
      ),
    );
  }
}
