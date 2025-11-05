import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usm_connect/pages/login_page.dart';
import 'firebase_options.dart';

// Importa el nuevo archivo que acabamos de crear
import 'package:usm_connect/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
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
      title: 'Firestore Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      // Aquí llamamos a tu nueva HomePage
      home: const LoginPage(),
    );
  }
}