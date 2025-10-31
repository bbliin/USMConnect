// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase para cualquier plataforma (web, android, etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: const FirestoreDemo(),
    );
  }
}

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

class FirestoreDemo extends StatefulWidget {
  const FirestoreDemo({super.key});

  @override
  State<FirestoreDemo> createState() => _FirestoreDemoState();
}

class _FirestoreDemoState extends State<FirestoreDemo> {
  final projects = FirebaseFirestore.instance.collection('projects');

  Future<void> _addProject() async {
    await projects.add({
      'title': 'Proyecto ${DateTime.now().second}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _delete(DocumentReference ref) async {
    await ref.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión con Firestore jeje'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Si algún doc tiene createdAt = null, igual funciona; los ordena al final/inicio
        stream: projects.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Sin proyectos. Toca + para crear uno.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>? ?? {};
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
