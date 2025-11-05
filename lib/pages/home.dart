import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Esta función de ayuda se queda en este archivo,
// ya que solo la usa _HomePageState.
DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate(); // caso normal
  if (v is Map) {
    final s = v['_seconds'] ?? v['seconds'];
    final ns = v['_nanoseconds'] ?? v['nanoseconds'] ?? 0;
    if (s is int) {
      final ms = s * 1000 + (ns is int ? (ns / 1e6).round() : 0);
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
  }
  if (v is String) {
    return DateTime.tryParse(v);
  }
  return null;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Referencia a la colección 'projects' en Firestore
  final projects = FirebaseFirestore.instance.collection('projects');

  Future<void> _addProject() async {
    await projects.add({
      'title': 'Proyecto ${DateTime.now().second}',
      'createdAt': FieldValue.serverTimestamp(), // Usa la hora del servidor
    });
  }

  Future<void> _delete(DocumentReference ref) async {
    await ref.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión con Firestore'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escucha los cambios en la colección, ordenados por fecha
        stream: projects.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          // Manejo de errores
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Muestra un indicador de carga mientras espera datos
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Muestra un mensaje si la lista está vacía
          if (docs.isEmpty) {
            return const Center(
                child: Text('Sin proyectos. Toca + para crear uno.'));
          }

          // Construye la lista de proyectos
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final doc = docs[i];
              // Convierte los datos del documento a un Mapa
              final data = doc.data() as Map<String, dynamic>? ?? {};
              
              // Obtiene los datos de forma segura
              final title = (data['title'] ?? 'Sin título').toString();
              final dt = _asDate(data['createdAt']);
              final fecha = dt != null ? dt.toLocal().toString() : 'sin fecha';

              return ListTile(
                title: Text(title),
                subtitle: Text(fecha),
                trailing: IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(doc.reference),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}