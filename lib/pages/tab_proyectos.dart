import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabProyectos extends StatelessWidget {
  const TabProyectos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Escucha en tiempo real los cambios de Firestore
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('fecha_creacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si ocurre un error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Si no hay proyectos
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay proyectos agregados aún',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Mostrar los proyectos
          final proyectos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              final data = proyecto.data() as Map<String, dynamic>;

              return Card(
                color: const Color(0xFFE3F2FD),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    data['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        data['descripcion'] ?? 'Sin descripción',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Responsable: ${data['responsable'] ?? 'Desconocido'}',
                        style: const TextStyle(
                            fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                      if (data['fecha_creacion'] != null)
                        Text(
                          'Fecha: ${_formatearFecha(data['fecha_creacion'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  //leading: const Icon(Icons.folder, color: Color(0xFF005A9C)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Función auxiliar para mostrar fecha legible
  static String _formatearFecha(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
