import 'package:flutter/material.dart';

class TabAgregarProyecto extends StatefulWidget {
  const TabAgregarProyecto({super.key});

  @override
  State<TabAgregarProyecto> createState() => _TabAgregarProyectoState();
}

class _TabAgregarProyectoState extends State<TabAgregarProyecto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(title: Text('Vista Agregar Proyecto')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}