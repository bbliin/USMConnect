import 'package:flutter/material.dart';
import 'package:usm_connect/utils/formatters.dart';
import 'tag_widget.dart';

class ProyectoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final PageController pageController;

  const ProyectoCard({
    super.key,
    required this.data,
    required this.index,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 1.0;

        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          value = (1 - (value.abs() * 0.2)).clamp(0.85, 1.0);
        }

        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final titulo = data['nombre'] ?? 'Sin nombre';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final responsable = data['responsable'] ?? 'Desconocido';
    final carreras = List<String>.from(data['carreras_relacionadas'] ?? []);
    final habilidades = List<String>.from(data['habilidades'] ?? []);

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: const Color.fromARGB(255, 255, 255, 255), 
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Descripción
            Text(
              descripcion,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // Responsable
            Text(
              'Responsable: $responsable',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 10),

            // Carreras
            if (carreras.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: carreras
                    .map((c) => TagWidget(
                          text: c,
                          background: const Color(0xFF1565C0),
                          textColor: Colors.white,
                        ))
                    .toList(),
              ),

            const SizedBox(height: 6),

            // Habilidades
            if (habilidades.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: habilidades
                    .map((h) => TagWidget(
                          text: h,
                          background: const Color(0xFFFFD54F),
                          textColor: Colors.black87,
                        ))
                    .toList(),
              ),

            const Spacer(),

            // Fecha
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
