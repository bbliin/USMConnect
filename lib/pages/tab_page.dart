import 'package:flutter/material.dart';
import 'package:usm_connect/pages/tab_proyectos.dart';
import 'package:usm_connect/pages/tab_perfil.dart';
import 'package:usm_connect/pages/tab_agregar_proyecto.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.alwaysHide;

  final List<Map<String, dynamic>> _paginas = [
    {
      'pagina': TabProyectos(),
      'texto': 'Proyectos',
      'icon': Icons.folder,
    },
    {
      'pagina': TabAgregarProyecto(),
      'texto': 'Agregar',
      'icon': Icons.add_circle,
    },
        {
      'pagina': TabPerfil(),
      'texto': 'Perfil',
      'icon': Icons.account_circle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USM Connect'), 
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF005A9C),
      ),

      body: _paginas[currentPageIndex]['pagina'],

      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        backgroundColor: const Color(0xFF005A9C),
        indicatorColor: const Color.fromARGB(224, 255, 255, 255).withValues(alpha: 0.2),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(_paginas[0]['icon']),
            label: _paginas[0]['texto'],
          ),
          NavigationDestination(
            icon: Icon(_paginas[1]['icon']),
            label: _paginas[1]['texto'],
          ),
          NavigationDestination(
            icon: Icon(_paginas[2]['icon']),
            label: _paginas[2]['texto'],
          ),
        ],
      ),
    );
  }
}
