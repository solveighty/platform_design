import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/main.dart';
import 'package:platform_design/src/pages/empty_form.dart';
import 'package:platform_design/src/pages/empty_form_login.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import '../../news_tab.dart';
import '../../profile_tab.dart';
import '../../songs_tab.dart';
import 'login_failed.dart';

Widget _buildIosHomePage(BuildContext context) {
  return CupertinoTabScaffold(
    tabBar: CupertinoTabBar(
      items: const [
        BottomNavigationBarItem(
          label: SongsTab.title,
          icon: Icon(Icons.assistant_outlined),
        ),
        BottomNavigationBarItem(
            label: NewsTab.title, icon: Icon(Icons.add_a_photo_outlined)),
        BottomNavigationBarItem(
          label: ProfileTab.title,
          icon: Icon(Icons.auto_awesome_mosaic_rounded),
        ),
      ],
    ),
    tabBuilder: (context, index) {
      assert(index <= 2 && index >= 0, 'Unexpected tab index: $index');
      return switch (index) {
        0 => CupertinoTabView(
            defaultTitle: SongsTab.title,
            builder: (context) => SongsTab(key: songsTabKey),
          ),
        1 => CupertinoTabView(
            defaultTitle: NewsTab.title,
            builder: (context) => const NewsTab(),
          ),
        2 => CupertinoTabView(
            defaultTitle: ProfileTab.title,
            builder: (context) => const ProfileTab(),
          ),
        _ => const SizedBox.shrink(),
      };
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _usuarioController = TextEditingController();
  TextEditingController _correoController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();

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
            'INGRESO',
            style: TextStyle(
                fontFamily: 'Blacknorthdemo',
                fontSize: 35.0,
                color: Colors.black),
          ),
          TextField(
            controller: _usuarioController,
            autofocus: true,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                hintText: "Ingrese su nombre de usuario",
                hintStyle: (TextStyle(color: Colors.white)),
                labelText: "Usuario",
                suffixIcon: Icon(Icons.verified_user),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0))),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: _correoController,
              decoration: InputDecoration(
                  hintText: "Ingrese su correo electrónico",
                  hintStyle: (TextStyle(color: Colors.white)),
                  labelText: "Correo Electrónico",
                  suffixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0)))),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _contrasenaController,
            decoration: InputDecoration(
                hintText: "Ingrese su contraseña",
                hintStyle: (TextStyle(color: Colors.white)),
                labelText: "Contraseña",
                suffixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0))),
            obscureText: true,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150, // Ajusta el ancho del primer botón
                child: FloatingActionButton(
                  hoverColor: Colors.greenAccent[200],
                  onPressed: () async {
                    String usuario = _usuarioController.text;
                    String correo = _correoController.text;
                    String contrasena = _contrasenaController.text;

                    // Verificar si al menos un campo está vacío
                    if (usuario.isEmpty ||
                        correo.isEmpty ||
                        contrasena.isEmpty) {
                      // Mostrar mensaje de error o redirigir a la página de fallo de inicio de sesión
                      final route = MaterialPageRoute(
                          builder: (context) => EmptyFormLogin());
                      Navigator.push(context, route);
                      return; // Salir del método para evitar ejecutar el resto del código
                    }

                    // Todos los campos están llenos, proceder con la verificación de inicio de sesión
                    bool loginSuccessful =
                        await verifyLogin(usuario, correo, contrasena);

                    if (loginSuccessful) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _buildIosHomePage(context)),
                      );
                    } else {
                      // Mostrar mensaje de error o redirigir a la página de fallo de inicio de sesión
                      final route = MaterialPageRoute(
                          builder: (context) => LoginFailed());
                      Navigator.push(context, route);
                    }

                    setState(() {});
                  },
                  backgroundColor: Colors.red[200],
                  child: Text(
                    'Ingresar',
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
        ],
      )),
    );
  }

  Future<bool> verifyLogin(
      String usuario, String correo, String contrasena) async {
    CollectionReference collectionReference = db.collection('registros');

    // Consulta
    QuerySnapshot queryPeople = await collectionReference.get();

    // Iterar
    for (QueryDocumentSnapshot document in queryPeople.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      if (data['usuario'] == usuario &&
          data['correo'] == correo &&
          data['contrasena'] == contrasena) {
        // Usuario encontrado en la base de datos
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: correo,
          password: contrasena,
        );

        if (userCredential.user != null) {
          // Autenticación exitosa
          return true;
        }
      }
    }
    return false;
  }
}
