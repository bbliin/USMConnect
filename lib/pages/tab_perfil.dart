import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usm_connect/pages/login_page.dart';


class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _eliminarProyecto(String idProyecto) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(idProyecto)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Proyecto eliminado")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF005A9C),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Mi perfil USM",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        user?.email ?? "Usuario Anónimo",
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Boton de cerrar sesion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _mostrarAlertaCerrarSesion();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar Sesion"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de proyectos del usuario
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .where('responsable', isEqualTo: user?.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    "No has publicado proyectos aún.",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                final proyectos = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proyectos.length,
                  itemBuilder: (context, index) {
                    final p = proyectos[index];
                    final data = p.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          data['nombre'] ?? 'Proyecto sin título',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmarEliminarProyecto(p.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  void _mostrarAlertaCerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar Sesion"),
          content: const Text("¿Está seguro de que desea salir?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Salir", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion();
              },
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut();

      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.clear();


      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {

      print("Error al cerrar sesion: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al intentar cerrar sesion")),
        );
      }
    }
  }

  void _confirmarEliminarProyecto(String idProyecto) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Eliminar Proyecto"),
      content: const Text("¿Seguro que quieres borrar este proyecto?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _eliminarProyecto(idProyecto);
          },
          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
}