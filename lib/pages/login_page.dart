// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<StatefulWidget> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage>{
//   TextEditingController emailctrl = TextEditingController();
//   TextEditingController passwordctrl = TextEditingController();
//   String errortext = '';

  
// }







import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _mensaje = '';

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() => _mensaje = '✅ Sesión iniciada correctamente');
    } catch (e) {
      setState(() => _mensaje = '❌ Error: ${e.toString()}');
    }
  }

  Future<void> _registrar() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() => _mensaje = '✅ Usuario registrado correctamente');
    } catch (e) {
      setState(() => _mensaje = '❌ Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Iniciar sesión')),
            ElevatedButton(onPressed: _registrar, child: const Text('Registrar nuevo usuario')),
            const SizedBox(height: 20),
            Text(_mensaje),
          ],
        ),
      ),
    );
  }
}






