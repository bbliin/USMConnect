import 'package:flutter/material.dart';
import 'package:usm_connect/utils/formatters.dart';
import 'tag_widget.dart';

class ProyectoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProyectoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final titulo      = data['nombre'] ?? 'Sin nombre';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final responsable = data['responsable'] ?? 'Desconocido';
    final carreras    = List<String>.from(data['carreras_relacionadas'] ?? []);
    final habilidades = List<String>.from(data['habilidades'] ?? []);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

            Text(
              responsable,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),

            if (carreras.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: carreras
                    .map((c) => TagWidget(
                          text: c,
                          background: const Color(0xFF1565C0),
                          textColor: Colors.white,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 4),
            ],

            if (habilidades.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: habilidades
                    .map((h) => TagWidget(
                          text: h,
                          background: const Color(0xFFFFD54F),
                          textColor: Colors.black87,
                        ))
                    .toList(),
              ),

            const SizedBox(height: 6),

            if (data['fecha_creacion'] != null)
              Text(
                'Publicado el ${formatFecha(data['fecha_creacion'])}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
