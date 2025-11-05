import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/retro_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'pages/home_page.dart';
import 'auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sneaker Store 👟',
        theme: RetroTheme.theme, // 🎨 Áp dụng giao diện retro nâu - kem
        home: const AppEntryPoint(),
      ),
    );
  }
}

/// Widget kiểm tra trạng thái đăng nhập Firebase
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  /// Kiểm tra người dùng đã đăng nhập hay chưa
  Future<void> _checkLogin() async {
    await Future.delayed(
        const Duration(milliseconds: 400)); // đợi Firebase khởi tạo
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _loggedIn = user != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: RetroTheme.beige,
        body: Center(
          child: CircularProgressIndicator(color: RetroTheme.brown),
        ),
      );
    }

    return _loggedIn ? const HomePage() : const LoginPage();
  }
}
