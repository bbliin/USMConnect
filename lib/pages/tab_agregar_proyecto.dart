import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabAgregarProyecto extends StatefulWidget {
  const TabAgregarProyecto({super.key});

  @override
  State<TabAgregarProyecto> createState() => _TabAgregarProyectoState();
}

class _TabAgregarProyectoState extends State<TabAgregarProyecto> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _responsableController = TextEditingController();

  bool _isLoading = false;

  // Función para guardar en Firestore
  Future<void> _agregarProyecto() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance.collection('projects').add({
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'responsable': _responsableController.text.trim(),
          'fecha_creacion': Timestamp.now(),
        });

        // Limpia los campos
        _nombreController.clear();
        _descripcionController.clear();
        _responsableController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto agregado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Agregar nuevo proyecto',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del proyecto',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingrese un nombre' : null,
            ),
            const SizedBox(height: 16),

            // Campo descripción
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Ingrese una descripción'
                  : null,
            ),
            const SizedBox(height: 16),

            // Campo responsable
            TextFormField(
              controller: _responsableController,
              decoration: const InputDecoration(
                labelText: 'Responsable',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botón para guardar
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005A9C),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isLoading ? null : _agregarProyecto,
              icon: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isLoading ? 'Guardando...' : 'Guardar proyecto',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _responsableController.dispose();
    super.dispose();
  }
}