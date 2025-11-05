import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'package:usm_connect/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(MdiIcons.firebase, color: Colors.yellow),
        title: Text(
          'Productos Firestore',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (opcion) async {
              await FirebaseAuth.instance.signOut();
              // Es una buena práctica verificar si el widget sigue montado
              // antes de navegar, especialmente después de una operación async.
              if (mounted) { 
                MaterialPageRoute route = MaterialPageRoute(
                  builder: (context) => LoginPage(),
                );
                Navigator.pushReplacement(context, route);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Salir'), value: 'logout'),
            ],
          ),
        ],
      ),
      // Agrega aquí el body de tu Scaffold
      body: Center(
        child: Text('Contenido de la página de productos'),
      ),
    ); // <-- Faltaba esta llave de cierre para Scaffold
  } // <-- Faltaba esta llave de cierre para el método build
} // <-- Faltaba esta llave de cierre para la clase _HomePageState