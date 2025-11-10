import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usm_connect/pages/login_page.dart';
import 'firebase_options.dart';

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
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF005A9C),
        indicatorColor: Colors.white.withOpacity(0.2),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Colors.white),
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white),
        ),
      ),
    ),
    home: const LoginPage(),
  );
  }
}