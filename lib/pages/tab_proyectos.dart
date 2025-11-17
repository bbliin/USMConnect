import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay proyectos agregados aún',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final proyectos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              final data = proyecto.data() as Map<String, dynamic>;

              final String titulo = data['nombre'] ?? 'Sin nombre';
              final String descripcion =
                  data['descripcion'] ?? 'Sin descripción';

              final List<String> carreras =
                  List<String>.from(data['carreras_relacionadas'] ?? []);
              final List<String> habilidades =
                  List<String>.from(data['habilidades'] ?? []);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), 
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        descripcion,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      if (carreras.isNotEmpty) ...[
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: carreras
                              .map(
                                (c) => _buildTag(
                                  text: c,
                                  background: const Color(0xFF1565C0),
                                  textColor: Colors.white,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                      ],

                      if (habilidades.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: habilidades
                              .map(
                                (h) => _buildTag(
                                  text: h,
                                  background: const Color(0xFFFFD54F),
                                  textColor: Colors.black87,
                                ),
                              )
                              .toList(),
                        ),

                      const SizedBox(height: 6),

                      if (data['fecha_creacion'] != null)
                        Text(
                          'Publicado el ${_formatearFecha(data['fecha_creacion'])}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _buildTag({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
        ),
      ),
    );
  }

  static String _formatearFecha(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
