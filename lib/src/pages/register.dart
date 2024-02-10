import 'package:aura_box/aura_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform_design/src/pages/google_auth.dart';
import 'package:platform_design/src/pages/register_complete.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:platform_design/utils.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseFirestore bd = FirebaseFirestore.instance;
  final _usuarioController = TextEditingController();
  final _nombre_apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombre_apellidoController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultAccentColor.defaultBackground,
      appBar: AppBar(
        title: AuraBox(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(0),
            ),
          ),
          spots: [
            AuraSpot(
              color: Colors.purple.shade300,
              radius: 500,
              alignment: const Alignment(0, 0.9),
              blurRadius: 50,
            ),
            AuraSpot(
              color: Colors.deepPurple.shade100,
              radius: 400,
              alignment: const Alignment(-1.2, 1.2),
              blurRadius: 50,
            ),
            AuraSpot(
              color: Colors.indigo.shade700,
              radius: 400,
              alignment: const Alignment(-0.5, -1.2),
              blurRadius: 50,
            ),
            AuraSpot(
              color: Colors.purpleAccent.shade700,
              radius: 300,
              alignment: const Alignment(1.2, -1.2),
              blurRadius: 100,
            ),
          ],
          child: Container(
            height: 50,
            child: Center(
              child: Text(
                "REGISTRO",
                textAlign: TextAlign.left,
                style: GoogleFonts.abel(
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        backgroundColor: DefaultAccentColor.defaultBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
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
              controller: _usuarioController,
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
              controller: _nombre_apellidoController,
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
              controller: _emailController,
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
              controller: _contrasenaController,
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
              onPressed: _signUp,
              child: Text(
                'REGISTRAR',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: DefaultAccentColor.accentPressed,
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

  void _signUp() async {
    String username = _usuarioController.text;
    String nombre = _nombre_apellidoController.text;
    String email = _emailController.text;
    String password = _contrasenaController.text;

    if (username.isEmpty || nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Llene los datos.'),
        ),
      );
      return;
    }

    if (username.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Su nombre de usuario debe tener almenos 5 caracteres.'),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La contraseña debe tener al menos 8 caracteres.'),
        ),
      );
      return;
    }

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingrese un correo válido.'),
        ),
      );
      return;
    }

    try{
      User? user = await _auth.signUpWithEmailAndPasssword(email, password, context);

      if (user != null) {
        await _guardarDatosUsuario(user.uid, username, nombre, email);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RegisterComplete()));
      }
    }catch(e){
      if (e is FirebaseAuthException && e.code == 'email-already-in-use'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este correo ya ha sido registrado anteriormente'),
          ),
        );
      }
      return;
    }
  }

  Future<void> _guardarDatosUsuario(
      String userId, String username, String nombre, String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('registros')
          .doc(userId)
          .set({'usuario': username, 'nombre': nombre, 'email': email});
      print('Datos de usuario guardados correctamente en Firestore.');
    } catch (e) {
      print('Error al guardar los datos del usuario: $e');
    }
  }
}