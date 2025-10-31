import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Demo',
      home: const FirestoreDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirestoreDemo extends StatefulWidget {
  const FirestoreDemo({super.key});

  @override
  State<FirestoreDemo> createState() => _FirestoreDemoState();
}

class _FirestoreDemoState extends State<FirestoreDemo> {
  final CollectionReference projects =
      FirebaseFirestore.instance.collection('projects');

  void addProject() {
    projects.add({
      'title': 'Proyecto ${DateTime.now().second}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conexión con Firestore')),
      body: StreamBuilder<QuerySnapshot>(
        stream: projects.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? 'Sin título'),
                subtitle: Text(data['createdAt']?.toDate().toString() ?? ''),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}

