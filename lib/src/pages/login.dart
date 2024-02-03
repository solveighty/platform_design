import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/main.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_failed.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('register');
  
  TextEditingController _usuarioController = TextEditingController();
  TextEditingController _correoController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();

  Future<bool> verifyLogin(String usuario, String correo, String contrasena) async {
    CollectionReference collectionReference = db.collection('registros');

    //consulta
    QuerySnapshot queryPeople = await collectionReference.get();
    //iterar
    for (QueryDocumentSnapshot document in queryPeople.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      if (data['usuario'] == usuario &&
          data['correo'] == correo &&
          data['contrasena'] == contrasena) {
        return true; // Se encontró una coincidencia
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: ListView(
        padding: EdgeInsets.symmetric(
            /*horizontal: 600.0,
            vertical: 10.0*/
        ),
        children: <Widget> [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 115,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/principal_background.jpg'),
              ),
              Text(
                'INGRESO',
                style: TextStyle(
                  fontFamily: 'Blacknorthdemo',
                  fontSize: 50.0,
                ),
              ),
              TextField(
                controller: _usuarioController,
                autofocus: true,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15
                    ),
                    hintText: "Ingrese su nombre de usuario",
                    labelText: "Usuario",
                    suffixIcon: Icon(
                        Icons.verified_user
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    )
                ),
              ),
              Divider(
                height: 10,
              ),
              TextField(
                controller: _correoController,
                  decoration: InputDecoration(
                      hintText: "Ingrese su correo electrónico",
                      labelText: "Correo Electrónico",
                      suffixIcon: Icon(
                          Icons.alternate_email
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0)
                      )
                  )
              ),
              Divider(
                height: 10,
              ),
              TextField(
                controller: _contrasenaController,
                decoration: InputDecoration(
                    hintText: "Ingrese su contraseña",
                    labelText: "Contraseña",
                    suffixIcon: Icon(
                        Icons.lock
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    )
                ),
                obscureText: true,
              ),
              Divider(
                height: 10,
              ),
              SizedBox(
                width: 120,
                child: FloatingActionButton(
                  hoverColor: Colors.greenAccent[200],
                  onPressed: () async {
                    String usuario = _usuarioController.text;
                    String correo = _correoController.text;
                    String contrasena = _contrasenaController.text;

                    bool loginSuccessful = await verifyLogin(usuario, correo, contrasena);
                    if (loginSuccessful){
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PlatformAdaptingHomePage()));
                    } else {
                      final route = MaterialPageRoute(builder: (context) => LoginFailed());
                      Navigator.push(context, route);
                    }
                    setState(() {});
                  },
                  backgroundColor: Colors.red[200],
                  child: Text('Ingresar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.0,
                        fontFamily: 'Moonchild'
                    ),
                  ),
                ),
              ),
              Divider(
                height: 15,
              ),
              SizedBox(
                width: 120,
                child: FloatingActionButton(
                  hoverColor: Colors.greenAccent[200],
                  onPressed: (){
                    final route = MaterialPageRoute(builder: (context) => StartPageMonitoring());
                    Navigator.push(context, route);
                  },
                  backgroundColor: Colors.red[200],
                  child: Text('Volver',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.0,
                        fontFamily: 'Moonchild'
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}


