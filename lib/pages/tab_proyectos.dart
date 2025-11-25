import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usm_connect/widgets/proyecto_card.dart';

class TabProyectos extends StatefulWidget {
  const TabProyectos({super.key});

  @override
  State<TabProyectos> createState() => _TabProyectosState();
}

class _TabProyectosState extends State<TabProyectos> {
  final List<String> _carreras = [
    'Ingeniería Civil Informática',
    'Ingeniería Civil Industrial',
    'Ingeniería Civil Electrónica',
    'Ingeniería Civil Mecánica',
    'Ingeniería Civil Eléctrica',
    'Ingeniería Civil Química',
    'Ingeniería Comercial',
    'Arquitectura',
  ];

  String? _carreraSeleccionada;

  final PageController pageController = PageController(viewportFraction: 0.88);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Dropdown para filtrar carrera
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Filtrar por carrera",
                border: OutlineInputBorder(),
              ),
              value: _carreraSeleccionada,
              onChanged: (value) {
                setState(() {
                  _carreraSeleccionada = value;
                });
              },
              items: _carreras.map((carrera) {
                return DropdownMenuItem(
                  value: carrera,
                  child: Text(carrera),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _buildStream(),
          ),
        ],
      ),
    );
  }


  // Este StreamBuilder aplica el filtro solo si hay carrera elegida
  Widget _buildStream() {
    Query query = FirebaseFirestore.instance
        .collection('projects')
        .orderBy('fecha_creacion', descending: true);

    if (_carreraSeleccionada != null) {
      query = query.where(
        'carreras_relacionadas',
        arrayContains: _carreraSeleccionada,
      );
    }

    // Filtrar en el cliente con comparación tolerante (trim, toLowerCase)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .orderBy('fecha_creacion', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error Firestore: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        // Si no hay filtro, muestra todo
        final proyectosFiltrados = (_carreraSeleccionada == null || _carreraSeleccionada!.isEmpty)
          ? docs
          : docs.where((doc) {
              final raw = doc['carreras_relacionadas'];
              if (raw == null) return false;
              final lista = List<String>.from(raw);
              // normalizamos: trim y comparacion case-insensitive
              return lista.any((s) =>
                s.toString().trim().toLowerCase() ==
                _carreraSeleccionada!.trim().toLowerCase()
              );
            }).toList();

        if (proyectosFiltrados.isEmpty) {
          return const Center(child: Text('No hay proyectos para esta carrera'));
        }

        return PageView.builder(
          controller: pageController,
          itemCount: proyectosFiltrados.length,
          itemBuilder: (context, index) {
            final data = proyectosFiltrados[index].data() as Map<String, dynamic>;
            return ProyectoCard(
              data: data,
              index: index,
              pageController: pageController,
            );
          },
        );
      },
    );

  }
}
