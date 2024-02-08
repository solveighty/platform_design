import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform_design/main.dart';
import 'package:platform_design/src/pages/empty_form.dart';
import 'package:platform_design/src/pages/google_auth.dart';
import 'package:platform_design/src/pages/invalid_email.dart';
import 'package:platform_design/src/pages/register_complete.dart';
import 'package:platform_design/src/pages/same_mail.dart';
import 'package:platform_design/src/pages/same_user.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import '../../news_tab.dart';
import '../../profile_tab.dart';
import '../../songs_tab.dart';


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              final route = MaterialPageRoute(
                  builder: (context) => StartPageMonitoring());
              Navigator.push(context, route);
            },
            icon: Icon(Icons.navigate_before_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/principal_background.jpg'),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'INGRESA TUS DATOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Blacknorthdemo',
                fontSize: 25.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _usuario,
              decoration: InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.verified_user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _nombre,
              decoration: InputDecoration(
                labelText: 'Nombre y Apellido',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _correo,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _contrasena,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {},
              child: Text(
                'REGISTRAR',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
