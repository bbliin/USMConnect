import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  String errorTexto = '';

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(MdiIcons.firebase, color: Colors.yellow,),
        title: Text("Inicio de sesión", style: TextStyle(color:Colors.white),),
      ),
      body: Padding(padding: EdgeInsets.all(10), 
      child:Column(
        children: [
          recuadroEmail(),
          recuadroContrasena(),
          //botonLogin
          mensajeError(),
        ],
      )),

    );
  }

  TextFormField recuadroEmail() {
    return TextFormField(
      controller: email_controller,
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
    );
  }

  TextFormField recuadroContrasena() {
    return TextFormField(
      controller: password_controller,
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
    );
  }

  Container mensajeError() {
    return Container(
      child: Text(errorTexto, style: TextStyle(color: Colors.red)),
    );
  }
}