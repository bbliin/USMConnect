import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usm_connect/widgets/proyecto_card.dart';

class TabProyectos extends StatelessWidget {
  const TabProyectos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('fecha_creacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay proyectos agregados aún',
              ),
            );
          }

          final proyectos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final data = proyectos[index].data() as Map<String, dynamic>;
              return ProyectoCard(data: data);
            },
          );
        },
      ),
    );
  }
}
