import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usm_connect/authentication/login_page.dart';
import 'package:usm_connect/pages/tab_agregar_proyecto.dart';
import 'dart:developer' as developer;

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil> {
  final User? user = FirebaseAuth.instance.currentUser;

  // --- VARIABLES ---
  bool _isSaving = false;
  String _avatarSeleccionado = "assets/images/image1.jpg"; // Imagen por defecto

  final List<String> _listaAvatars = [
    "assets/images/image1.jpg",
    "assets/images/image2.jpg",
    "assets/images/image3.jpg",
    "assets/images/image4.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }




  Future<void> _cargarDatosUsuario() async {
    if (user == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          if (data['photoUrl'] != null && data['photoUrl'] != '') {
            _avatarSeleccionado = data['photoUrl'];
          }
        });
      }
    } catch (e) {
      developer.log("Error cargando perfil: $e");
    }
  }


  Future<void> _guardarPerfil() async {
    if (user == null) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': user!.email,
        'photoUrl': _avatarSeleccionado,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto de perfil actualizada")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }


  void _mostrarSelectorAvatars() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Elige tu avatar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _listaAvatars.length,
                  itemBuilder: (context, index) {
                    final path = _listaAvatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarSeleccionado = path;
                        });
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundImage: AssetImage(path),
                        backgroundColor: Colors.grey[200],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _eliminarProyecto(String idProyecto) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(idProyecto)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Proyecto eliminado")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar: $e")),
      );
    }
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
      developer.log("Error al cerrar sesión", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al intentar cerrar sesion")),
        );
      }
    }
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
              onPressed: () => Navigator.of(context).pop(),
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TARJETA DE PERFIL
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _mostrarSelectorAvatars,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(_avatarSeleccionado),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.edit,
                                  color: Colors.blue, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text("Mi Perfil USM",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(user?.email ?? "Usuario Anónimo",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _guardarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005A9C),
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("Guardar Foto"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _mostrarAlertaCerrarSesion,
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                          title: const Text("Editar Proyecto")),
                                      body: TabAgregarProyecto(
                                        proyectoId: p.id,
                                        dataInicial: data,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _confirmarEliminarProyecto(p.id),
                            ),
                          ],
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
}