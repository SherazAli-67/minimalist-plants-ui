import 'package:go_router/go_router.dart';
import 'package:plants_app_ui/presentation/screens/cart_screen.dart';
import 'package:plants_app_ui/presentation/screens/home_screen.dart';
import 'package:plants_app_ui/presentation/screens/welcome_screen.dart';

GoRouter router = GoRouter(
  initialLocation: NamedRoutes.welcome.routeName,
  routes: [
    GoRoute(path: NamedRoutes.welcome.routeName, builder: (ctx, state) => WelcomeScreen()),
    GoRoute(path: NamedRoutes.home.routeName, builder: (ctx, state) => HomeScreen()),
    GoRoute(path: NamedRoutes.cart.routeName, builder: (ctx, state) => CartScreen()),
  ],
);

enum NamedRoutes {
  welcome('/welcome'),
  home('/home'),
  cart('/cart');

  final String routeName;
  const NamedRoutes(this.routeName);
}
