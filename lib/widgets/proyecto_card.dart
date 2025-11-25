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
            // ---- TÍTULO ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5FE), // celeste claro
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ---- DESCRIPCIÓN ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFF9C4), // amarillo claro
              child: Text(
                descripcion,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 10),

            // ---- RESPONSABLE ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFE0B2), // naranjo claro
              child: Text(
                "Contactar: $responsable",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 10),

            // ---- CARRERAS Y HABILIDADES ----
            
            IntrinsicHeight(
              child: Row(
                children: [
                  // --- CARRERAS ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFC8E6C9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Carreras",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // --- HABILIDADES ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFD1C4E9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Habilidades",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
