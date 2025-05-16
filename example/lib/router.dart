// import 'package:go_router/go_router.dart';
// import 'package:image_style_transform/utils/router.dart';

// import 'app_navigator.dart';
// import 'app_screen.dart';
// import 'di.dart';
// import 'home_screen.dart';

// GoRouter initRouter() {
//   final navigatorKey = getIt.get<AppNavigator>().navigatorKey;
//   return GoRouter(
//     navigatorKey: navigatorKey,
//     initialLocation: AppScreen.home.route,
//     routes:
//         [
//           GoRoute(
//             path: AppScreen.home.route,
//             parentNavigatorKey: navigatorKey,
//             name: AppScreen.home.name,
//             builder: (context, state) => HomeScreen(),
//           ),
//         ] +
//         imageGalleryRoutes(navigatorKey),
//   );
// }
