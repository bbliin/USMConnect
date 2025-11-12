import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usm_connect/pages/tab_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  String errorText = '';
  bool isLoading = false; // Para mostrar un indicador de carga

  // Color principal de la UI
  final Color primaryColor = const Color(0xFF005A9C); // Azul UTFSM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          // Center para centrar la tarjeta
          child: SingleChildScrollView(
            // Para evitar overflow con el teclado
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    // --- Icono y Títulos ---
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor,
                      child: const Icon(
                        Icons.school, // Icono de birrete
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "UTFSM Connect",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Conecta con estudiantes y proyectos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // campos de Texto
                    campoEmail(),
                    const SizedBox(height: 16),
                    campoPassword(),
                    const SizedBox(height: 24),


                    isLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : botonLogin(),
                    mensajeError(),
                    const SizedBox(height: 8), // Espacio antes del link

                    // Link de registro 
                    botonRegistro(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField campoEmail() {
    return TextFormField(
      controller: emailCtrl,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'tu.email@usm.cl',
        // Borde redondeado
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  TextFormField campoPassword() {
    return TextFormField(
      controller: passwordCtrl,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      obscureText: true,
    );
  }

  Container mensajeError() {
    return Container(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        errorText,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container botonLogin() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {

          setState(() {
            isLoading = true; 
            errorText = '';
          });

          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailCtrl.text.trim(),
              password: passwordCtrl.text.trim(),
            );
            SharedPreferences sp = await SharedPreferences.getInstance();
            sp.setString('user_email', emailCtrl.text.trim());


            if (!mounted) return;

            // ======================== Navegar a la página de TABS ==========================
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => TabsPage(),
            );
            Navigator.pushReplacement(context, route);
          } on FirebaseAuthException catch (ex) {
            switch (ex.code) {
              case 'user-not-found':
                errorText = 'Usuario no existe';
                break;
              case 'invalid-email':
                errorText = 'Formato de correo inválido';
                break;
              case 'wrong-password':
                errorText = 'Contraseña incorrecta';
                break;
              case 'user-disabled':
                errorText = 'Cuenta desactivada';
                break;
              case 'invalid-credential':
                errorText = 'Credenciales inválidas';
                break;
              default:
                errorText = 'Error desconocido';
            }
          } finally {
            // Ocultar indicador de carga y mostrar error si lo hay
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
      
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), 
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Iniciar Sesión'),
      ),
    );
  }

  Widget botonRegistro() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          text: '¿No tienes cuenta? ',
          style: TextStyle(color: Colors.black54, fontSize: 15),
          children: [
            TextSpan(
              text: 'Regístrate',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              recognizer: TapGestureRecognizer()
                ..onTap = () {

                  print('Navegar a la página de registro (TODAVIA NO IMPLEMENTADO)');
                },
            ),
          ],
        ),
      ),
    );
  }
}