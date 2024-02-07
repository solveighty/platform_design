import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/src/pages/empty_form.dart';
import 'package:platform_design/src/pages/invalid_email.dart';
import 'package:platform_design/src/pages/register_complete.dart';
import 'package:platform_design/src/pages/same_mail.dart';
import 'package:platform_design/src/pages/same_user.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _usuario = TextEditingController();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _usuario.dispose();
    _nombre.dispose();
    _contrasena.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addUsers(
      String usuario, String nombre, String correo, String contrasena) async {
    if (usuario.isEmpty ||
        nombre.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty) {
      final route =
          MaterialPageRoute(builder: (context) => const EmptyFormRegister());
      Navigator.push(context, route);
      return;
    }
    try {
      QuerySnapshot existingUsers = await FirebaseFirestore.instance
          .collection('registros')
          .where('usuario', isEqualTo: usuario)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        final route =
            MaterialPageRoute(builder: (context) => const SameUserFunc());
        Navigator.push(context, route);
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: correo, password: contrasena);

        if (userCredential.user != null) {
          await userCredential.user?.sendEmailVerification();

          await FirebaseFirestore.instance.collection('registros').add({
            'usuario': usuario,
            'nombre&apellido': nombre,
            'correo': correo,
            'contrasena': contrasena,
          });

          final route =
              MaterialPageRoute(builder: (context) => const RegisterComplete());
          Navigator.push(context, route);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final route =
            MaterialPageRoute(builder: (context) => const SameMailFunc());
        Navigator.push(context, route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/principal_background.jpg'),
              ),
            ]),
            Text(
              'REGISTRO',
              style: TextStyle(
                  fontFamily: 'Blacknorthdemo',
                  fontSize: 35.0,
                  color: Colors.black),
            ),
            TextField(
              controller: _usuario,
              autofocus: true,
              enableInteractiveSelection: false,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  hintText: "Registre su nombre de usuario",
                  hintStyle: (TextStyle(color: Colors.white)),
                  labelText: "Usuario",
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0))),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: _nombre,
              decoration: InputDecoration(
                  hintText: "Ingrese su nombre y apellido",
                  hintStyle: (TextStyle(color: Colors.white)),
                  labelText: "Nombre y Apellido",
                  suffixIcon: Icon(Icons.man),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0))),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
                controller: _correo,
                decoration: InputDecoration(
                    hintText: "Ingrese su correo electrónico",
                    hintStyle: (TextStyle(color: Colors.white)),
                    labelText: "Correo Electrónico",
                    suffixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)))),
            SizedBox(
              height: 8,
            ),
            TextField(
                controller: _contrasena,
                decoration: InputDecoration(
                    hintText: "Ingrese su contraseña",
                    hintStyle: (TextStyle(color: Colors.white)),
                    labelText: "Contraseña",
                    suffixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                obscureText: true),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    hoverColor: Colors.greenAccent[200],
                    onPressed: () async {
                      if (EmailValidator.validate(_correo.text.trim())) {
                        if (_contrasena.text.trim().length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'La contraseña debe tener 8 caracteres como mínimo')));
                        } else {
                          addUsers(
                            _usuario.text.trim(),
                            _nombre.text.trim(),
                            _correo.text.trim(),
                            _contrasena.text.trim(),
                          );
                        }
                      } else {
                        final route = MaterialPageRoute(
                            builder: (context) => InvalidEmailFunc());
                        Navigator.push(context, route);
                      }
                    },
                    backgroundColor: Colors.red[200],
                    child: Text(
                      'Registrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.0,
                        fontFamily: 'Moonchild',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150, // Ajusta el ancho del segundo botón
                  child: FloatingActionButton(
                    hoverColor: Colors.greenAccent[200],
                    onPressed: () {
                      final route = MaterialPageRoute(
                        builder: (context) => StartPageMonitoring(),
                      );
                      Navigator.push(context, route);
                    },
                    backgroundColor: Colors.red[200],
                    child: Text(
                      'Volver',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.0,
                        fontFamily: 'Moonchild',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ])),
    );
  }
}
