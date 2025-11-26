import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabAgregarProyecto extends StatefulWidget {
  final String? proyectoId;
  final Map<String, dynamic>? dataInicial;

  const TabAgregarProyecto({super.key, this.proyectoId, this.dataInicial});

  @override
  State<TabAgregarProyecto> createState() => _TabAgregarProyectoState();
}

class _TabAgregarProyectoState extends State<TabAgregarProyecto> {
  final _formKey = GlobalKey<FormState>();

  // controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _habilidadPersonalizadaController = TextEditingController();

  // donde guardo lo que el usuario elige
  final Set<String> _selectedCarreras = {};
  final Set<String> _selectedHabilidades = {};

  bool _carrerasError = false;
  bool _habilidadesError = false;
  bool _isLoading = false;

  // opciones disponibles
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

  // habilidades base
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

  @override
  void initState() {
    super.initState();

    // si estamos editando, rellenamos todo con lo que ya estaba guardado
    if (widget.dataInicial != null) {
      _nombreController.text = widget.dataInicial!['nombre'] ?? '';
      _descripcionController.text = widget.dataInicial!['descripcion'] ?? '';

      if (widget.dataInicial!['carreras_relacionadas'] != null) {
        _selectedCarreras.addAll(
          List<String>.from(widget.dataInicial!['carreras_relacionadas']),
        );
      }

      if (widget.dataInicial!['habilidades'] != null) {
        _selectedHabilidades.addAll(
          List<String>.from(widget.dataInicial!['habilidades']),
        );

        // si habian habilidades personalizadas guardadas, las agregamos a la lista
        for (final hab in _selectedHabilidades) {
          if (!_habilidades.contains(hab)) _habilidades.add(hab);
        }
      }
    }
  }

  // función principal para guardar el proyecto
  Future<void> _agregarProyecto() async {
    final isValid = _formKey.currentState!.validate();

    // reviso si eligio al menos una carrera y una habilidad
    setState(() {
      _carrerasError = _selectedCarreras.isEmpty;
      _habilidadesError = _selectedHabilidades.isEmpty;
    });

    if (!isValid || _carrerasError || _habilidadesError) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // aqui preparo lo que voy a guardar
      final datos = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'responsable': user?.email ?? 'desconocido',
        'carreras_relacionadas': _selectedCarreras.toList(),
        'habilidades': _selectedHabilidades.toList(),
        if (widget.proyectoId == null) 'fecha_creacion': Timestamp.now(),
      };

      // si no hay id → es nuevo, si hay → editar
      if (widget.proyectoId == null) {
        await FirebaseFirestore.instance.collection('projects').add(datos);

        _nombreController.clear();
        _descripcionController.clear();
        _selectedCarreras.clear();
        _selectedHabilidades.clear();
        _habilidadPersonalizadaController.clear();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto agregado')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.proyectoId)
            .update(datos);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto actualizado')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // si pasa algo, aviso con un mensaje
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // funcion para agregar habilidades nuevas
  void _agregarHabilidadPersonalizada() {
    final texto = _habilidadPersonalizadaController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      if (!_habilidades.contains(texto)) _habilidades.add(texto);
      _selectedHabilidades.add(texto);
      _habilidadPersonalizadaController.clear();
      _habilidadesError = false;
    });
  }

  // estilo visual base para campos de texto
  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Publicar Proyecto', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // campos de texto
              TextFormField(
                controller: _nombreController,
                decoration: _inputDecoration(label: 'Título del Proyecto *'),
                validator: (value) => value!.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: _inputDecoration(label: 'Descripción *'),
                validator: (value) => value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 20),

              // carreras (checkbox)
              const Text('Carreras Relacionadas *', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: _carreras.map((c) {
                  return CheckboxListTile(
                    value: _selectedCarreras.contains(c),
                    onChanged: (value) {
                      setState(() {
                        value == true ? _selectedCarreras.add(c) : _selectedCarreras.remove(c);
                        _carrerasError = false;
                      });
                    },
                    title: Text(c),
                  );
                }).toList(),
              ),
              if (_carrerasError)
                const Text('Selecciona al menos una', style: TextStyle(color: Colors.red, fontSize: 12)),

              const SizedBox(height: 20),

              // habilidades (chips)
              const Text('Habilidades / Tecnologías *', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _habilidades.map((h) {
                  return FilterChip(
                    label: Text(h),
                    selected: _selectedHabilidades.contains(h),
                    onSelected: (value) {
                      setState(() {
                        value ? _selectedHabilidades.add(h) : _selectedHabilidades.remove(h);
                        _habilidadesError = false;
                      });
                    },
                  );
                }).toList(),
              ),
              if (_habilidadesError)
                const Text('Selecciona al menos una', style: TextStyle(color: Colors.red, fontSize: 12)),

              const SizedBox(height: 10),

              // input para agregar habilidad nueva
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _habilidadPersonalizadaController,
                      decoration: const InputDecoration(
                        hintText: 'Agregar habilidad personalizada',
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _agregarHabilidadPersonalizada,
                    child: const Text('Agregar'),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // botón final
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _agregarProyecto,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Guardando...' : 'Publicar Proyecto'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              )
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
    _habilidadPersonalizadaController.dispose();
    super.dispose();
  }
}
