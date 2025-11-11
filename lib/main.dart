import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'package:usm_connect/pages/login_page.dart';
import 'package:usm_connect/pages/tab_page.dart'; // TabsPage (Proyectos/Agregar/Perfil)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const USMConnectApp());
}

class USMConnectApp extends StatelessWidget {
  const USMConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USMConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF005A9C),
      ),
      routes: {
        '/tabs': (_) => const TabsPage(), // ← ruta para las 3 secciones
      },
      home: const _AuthGate(), // ← decide Login o Tabs según sesión
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasData) return const TabsPage(); // ya logueado → Tabs
        return const LoginPage();                   // no logueado → Login
      },
    );
  }
}
