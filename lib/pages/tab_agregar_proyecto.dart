import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabAgregarProyecto extends StatefulWidget {
  const TabAgregarProyecto({super.key});

  @override
  State<TabAgregarProyecto> createState() => _TabAgregarProyectoState();
}

class _TabAgregarProyectoState extends State<TabAgregarProyecto> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _responsableController = TextEditingController();

  bool _isLoading = false;

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

  final List<String> _habilidades = [
    'React',
    'Node.js',
    'Python',
    'Java',
    'Flutter',
    'Machine Learning',
    'Data Science',
    'UI/UX',
    'Backend',
    'Frontend',
    'Mobile',
    'IoT',
    'Cloud Computing',
    'Blockchain',
    'Ciberseguridad',
    'DevOps',
  ];

  final Set<String> _selectedCarreras = {};
  final Set<String> _selectedHabilidades = {};

  bool _carrerasError = false;
  bool _habilidadesError = false;

  Future<void> _agregarProyecto() async {
    final isValid = _formKey.currentState!.validate();

    setState(() {
      _carrerasError = _selectedCarreras.isEmpty;
      _habilidadesError = _selectedHabilidades.isEmpty;
    });

    if (!isValid || _carrerasError || _habilidadesError) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('projects').add({
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'responsable': _responsableController.text.trim(),
        'carreras_relacionadas': _selectedCarreras.toList(),
        'habilidades': _selectedHabilidades.toList(),
        'fecha_creacion': Timestamp.now(),
      });

      _nombreController.clear();
      _descripcionController.clear();
      _responsableController.clear();
      _selectedCarreras.clear();
      _selectedHabilidades.clear();

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

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF005A9C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),

              const Text(
                'Publicar Proyecto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Comparte tu idea con la comunidad',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombreController,
                decoration: _inputDecoration(
                  label: 'Título del Proyecto *',
                  hint: 'ej. Sistema de gestión de proyectos',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese un título para el proyecto'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  label: 'Descripción *',
                  hint:
                      'Describe tu proyecto y qué tipo de colaboradores buscas...',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _responsableController,
                decoration: _inputDecoration(
                  label: 'Responsable',
                  hint: 'Nombre de quien lidera el proyecto',
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Carreras Relacionadas *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Column(
                children: _carreras.map((carrera) {
                  final selected = _selectedCarreras.contains(carrera);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedCarreras.add(carrera);
                        } else {
                          _selectedCarreras.remove(carrera);
                        }
                        _carrerasError = false;
                      });
                    },
                    dense: true,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      carrera,
                      style: const TextStyle(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
              if (_carrerasError)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Selecciona al menos una carrera',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Habilidades / Tecnologías *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _habilidades.map((hab) {
                  final selected = _selectedHabilidades.contains(hab);
                  return FilterChip(
                    label: Text(hab),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedHabilidades.add(hab);
                        } else {
                          _selectedHabilidades.remove(hab);
                        }
                        _habilidadesError = false;
                      });
                    },
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              if (_habilidadesError)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Selecciona al menos una habilidad',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005A9C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _agregarProyecto,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Publicando...' : 'Publicar proyecto',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
