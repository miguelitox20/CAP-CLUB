import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';
import 'services/push_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'views/login_page.dart';
import 'views/product_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  // Espera a que Firebase restaure la sesión (si ya había una).
  await FirebaseAuth.instance.authStateChanges().first;

  // 2. Singleton de SharedPreferences.
  await StorageService().init();
  await StorageService().reconcileSession(FirebaseAuth.instance.currentUser?.email?.toLowerCase());

  // 3. Servicios.
  Get.put(AuthService(), permanent: true);
  Get.put(ProductService(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(PushService(), permanent: true);

  // 4. Controladores (el orden importa: cada uno busca a los anteriores).
  Get.put(AuthController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(OrderController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(FavoritesController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hayUsuario = Get.find<AuthController>().email.value != null;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAP / CLUB',
      theme: AppTheme.dark,
      home: hayUsuario ? const ProductPage() : const LoginPage(),
    );
  }
}
