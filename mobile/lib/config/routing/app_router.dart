import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/forget_password/controller/forget_password_cubit.dart';
import '../../modules/auth/forget_password/view/forget_passwod_screen.dart';
import '../../modules/auth/login/controller/login_cubit.dart';
import '../../modules/auth/login/view/login_screen.dart';
import '../../modules/auth/register/controller/register_cubit.dart';
import '../../modules/auth/register/view/register_screen.dart';
import '../../modules/common/force_upgrade/view/force_upgrade_screen.dart';
import '../../modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import '../../modules/common/navigation_bar/view/navigation_bar_screen.dart';
import '../../modules/common/notifications/view/notification_screen.dart';
import '../../modules/common/on_borarding/controller/on_boarding_bloc.dart';
import '../../modules/common/on_borarding/view/on_boarding_screen.dart';
import '../../modules/common/splash/view/splash_screen.dart';
import '../../modules/pages/cart/view/cart_screen.dart';
import '../../modules/pages/chat/view/chat_screen.dart';
import '../../modules/pages/checkout/view/checkout_screen.dart';
import '../../modules/pages/custom_order/view/custom_order_screen.dart';
import '../../modules/pages/custom_order_details/view/custom_order_details_screen.dart';
import '../../modules/pages/custom_orders_list/view/custom_orders_list_screen.dart';
import '../../modules/pages/favorites/view/favorites_screen.dart';
import '../../modules/pages/order_details/view/order_details_screen.dart';
import '../../modules/pages/orders/view/orders_screen.dart';
import '../../modules/pages/product_details/view/product_details_screen.dart';
import '../../modules/pages/products/view/products_screen.dart';
import '../../modules/pages/address_form/view/address_form_screen.dart';
import '../../modules/pages/addresses/view/addresses_screen.dart';
import '../../modules/pages/edit_profile/view/edit_profile_screen.dart';
import '../../placemarket_app.dart';
import '../app_controller/app_controller_cubit.dart';
import '../../core/models/address_models.dart';
import '../../core/models/app_models.dart';
import '../../core/utils/functions/service_locator.dart';
import 'app_router_keys.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: PlaceMarketApp.navigatorKey,
  initialLocation: AppRouterKeys.splash,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    getRouteInstance('/', (_) => const SplashScreen()),
    getRouteInstance(
      AppRouterKeys.onBoarding,
      (_) => BlocProvider(
        create: (_) => OnBoardingBloc(),
        child: const OnBoardingScreen(),
      ),
    ),
    getRouteInstance(AppRouterKeys.forceUpgrade, (state) {
      final extra = state.extra;
      final version = extra is AppVersionModel ? extra : const AppVersionModel();
      return ForceUpgradeScreen(version: version);
    }),
    getRouteInstance(
      AppRouterKeys.forgetPassword,
      (_) => BlocProvider(
        create: (_) => ForgetPasswordCubit(),
        child: const ForgetPasswordScreen(),
      ),
    ),
    getRouteInstance(
      AppRouterKeys.signUp,
      (_) => BlocProvider(
        create: (_) => RegisterCubit(),
        child: const RegisterScreen(),
      ),
    ),
    getRouteInstance(
      AppRouterKeys.signIn,
      (_) => BlocProvider(
        create: (_) => LoginCubit(),
        child: const LoginScreen(),
      ),
    ),
    getRouteInstance(
      AppRouterKeys.navigatorBarScreen,
      (_) => MultiBlocProvider(
        providers: [
          BlocProvider<AppControllerCubit>.value(
            value: sl.get<AppControllerCubit>(),
          ),
          BlocProvider(create: (_) => NavigationBarCubit()),
        ],
        child: const NavigationBarScreen(),
      ),
    ),
    getRouteInstance(AppRouterKeys.productDetails, (state) {
      final extra = state.extra;
      String id = '';
      if (extra is Map) id = extra['id']?.toString() ?? '';
      if (extra is String) id = extra;
      return ProductDetailsScreen(productId: id);
    }),
    getRouteInstance(AppRouterKeys.products, (state) {
      final extra = state.extra is Map ? state.extra as Map : {};
      return ProductsScreen(
        title: extra['title']?.toString(),
        categoryId: extra['categoryId']?.toString(),
        search: extra['search']?.toString(),
        query: extra['query'] is Map<String, dynamic>
            ? extra['query'] as Map<String, dynamic>
            : {},
      );
    }),
    getRouteInstance(AppRouterKeys.search, (state) {
      return const ProductsScreen();
    }),
    getRouteInstance(AppRouterKeys.notificationScreen, (_) => const NotificationScreen()),
    getRouteInstance(AppRouterKeys.cart, (_) => const CartScreen()),
    getRouteInstance(AppRouterKeys.checkout, (_) => const CheckOutScreen()),
    getRouteInstance(AppRouterKeys.myOrdersScreen, (_) => const OrdersScreen()),
    getRouteInstance(AppRouterKeys.orderDetails, (state) {
      final id = state.extra?.toString() ?? '';
      return OrderDetailsScreen(orderId: id);
    }),
    getRouteInstance(AppRouterKeys.customOrder, (_) => const CustomOrderScreen()),
    getRouteInstance(AppRouterKeys.myCustomOrders, (_) => const CustomOrdersListScreen()),
    getRouteInstance(AppRouterKeys.customOrderDetails, (state) {
      return CustomOrderDetailsScreen(orderId: state.extra?.toString() ?? '');
    }),
    getRouteInstance(AppRouterKeys.chat, (state) {
      return ChatScreen(orderId: state.extra?.toString() ?? '');
    }),
    getRouteInstance(AppRouterKeys.editProfile, (_) => const EditProfileScreen()),
    getRouteInstance(AppRouterKeys.addresses, (_) => const AddressesScreen()),
    getRouteInstance(AppRouterKeys.addressForm, (state) {
      return AddressFormScreen(
        initial: state.extra is AddressModel ? state.extra as AddressModel : null,
      );
    }),
    getRouteInstance(AppRouterKeys.favorites, (_) => const FavoritesScreen()),
  ],
);

GoRoute getRouteInstance(
  String path,
  Widget Function(GoRouterState state) screen,
) => GoRoute(
  path: path.contains('/') ? path : '/$path',
  name: path,
  builder: (BuildContext context, GoRouterState state) => screen(state),
);
