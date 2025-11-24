import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usm_connect/pages/tab_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de texto
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  String errorText = '';
  bool isLoading = false;

  // Color Institucional
  final Color primaryColor = const Color(0xFF005A9C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      // AppBar simple para poder volver atrás
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Crear Cuenta",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005A9C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Únete a la comunidad USM",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    //CAMPOS DE TEXTO
                    _campoTexto(emailCtrl, 'Email', Icons.email, false),
                    const SizedBox(height: 16),
                    _campoTexto(passwordCtrl, 'Contraseña', Icons.lock, true),
                    const SizedBox(height: 16),
                    _campoTexto(confirmPasswordCtrl, 'Confirmar Contraseña',
                        Icons.lock_outline, true),

                    const SizedBox(height: 24),

                    //MENSAJE DE ERROR
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          errorText,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    //BOTON DE REGISTRO
                    isLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _campoTexto(TextEditingController controller, String label,
      IconData icon, bool esPassword) {
    return TextFormField(
      controller: controller,
      obscureText: esPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  //LÓGICA DE REGISTRO
  void _registrarUsuario() async {
    // 1. Validar contraseñas iguales
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      setState(() {
        errorText = "Las contraseñas no coinciden";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = "";
    });

    try {
      // 2. Crear usuario en firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      // 3. Guardar sesión local
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setString('user_email', emailCtrl.text.trim());

      if (!mounted) return;

      // 4. Ir a la App Principal (TabsPage) eliminando historial
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TabsPage()),
        (route) => false,
      );
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Manejo de errores comunes de registro
        switch (e.code) {
          case 'email-already-in-use':
            errorText = "El correo ya está registrado";
            break;
          case 'weak-password':
            errorText = "La contraseña es muy débil (min 6 caracteres)";
            break;
          case 'invalid-email':
            errorText = "Formato de correo inválido";
            break;
          default:
            errorText = "Error: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        errorText = "Ocurrió un error inesperado";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}