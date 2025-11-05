import 'package:flutter/material.dart';
import 'package:usm_connect/pages/tab_proyectos.dart';
import 'package:usm_connect/pages/tab_perfil.dart';
import 'package:usm_connect/pages/tab_agregar_proyecto.dart';

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:const Color(0xFF005A9C),
          foregroundColor: Colors.white,
          title: const Text('USM Connect'), centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white, 
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Proyectos',),
              Tab(text: 'Agregar',),
              Tab(text: 'Perfil',),
            ]),
        ),
        body: const TabBarView(children: [
          TabProyectos(),
          TabAgregarProyecto(),
          TabPerfil()
        ]),
      ));
  }
}