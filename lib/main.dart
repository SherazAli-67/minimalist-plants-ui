import 'package:flutter/material.dart';
import 'package:plants_app_ui/constants/string_const.dart';
import 'package:plants_app_ui/routing/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: StringConst.appTitle,
      theme: ThemeData(
        brightness: .light,
      ),
      routerConfig: router,
      builder: (ctx, child) => child!,
    );
  }
}
