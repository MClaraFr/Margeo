import 'package:go_router/go_router.dart';

import '../../screens/auth/sign_in_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/plots/plots_screen.dart';
import '../../screens/applications/applications_screen.dart';
import '../../screens/products/products_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        name: AppRoutes.loginName,
        path: AppRoutes.login,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        name: AppRoutes.homeName,
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRoutes.plotsName,
        path: AppRoutes.plots,
        builder: (context, state) => const PlotsScreen(),
      ),
      GoRoute(
        name: AppRoutes.applicationsName,
        path: AppRoutes.applications,
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        name: AppRoutes.productsName,
        path: AppRoutes.products,
        builder: (context, state) => const ProductsScreen(),
      ),
    ],
  );
}
