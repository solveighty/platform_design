import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/src/pages/empty_form.dart';
import 'package:platform_design/src/pages/register_complete.dart';
import 'package:platform_design/src/pages/same_mail.dart';
import 'package:platform_design/src/pages/same_user.dart';
import 'package:platform_design/src/pages/startpage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _usuario = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose(){
    _usuario.dispose();
    _nombre.dispose();
    _apellido.dispose();
    _contrasena.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('register');


  Future addUsers(String usuario, String nombre, String apellido, String correo, String contrasena) async {
    QuerySnapshot existingMails = await FirebaseFirestore.instance
        .collection('registros')
        .where('correo', isEqualTo: correo)
        .get();
    QuerySnapshot existingUsers = await FirebaseFirestore.instance
        .collection('registros')
        .where('usuario', isEqualTo: usuario)
        .get();
    if(usuario.isEmpty || nombre.isEmpty || apellido.isEmpty || correo.isEmpty || contrasena.isEmpty){
      final route = MaterialPageRoute(builder: (context) => const EmptyFormRegister());
      Navigator.push(context, route);
    }
    else if(existingMails.docs.isNotEmpty){
      final route = MaterialPageRoute(builder: (context) => const SameMailFunc());
      Navigator.push(context, route);
    }
    else if(existingUsers.docs.isNotEmpty){
      final route = MaterialPageRoute(builder: (context) => const SameUserFunc());
      Navigator.push(context, route);
    }
    else{
      await FirebaseFirestore.instance.collection('registros').add({
        'usuario': usuario,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'contrasena': contrasena
      });
      final route = MaterialPageRoute(builder: (context) => const RegisterComplete());
      Navigator.push(context, route);
    }
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
                'REGISTRO',
                  style: TextStyle(
                  fontFamily: 'Blacknorthdemo',
                  fontSize: 50.0,
                ),
              ),
              TextField(
                controller: _usuario,
                autofocus: true,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15
                    ),
                  hintText: "Registre su nombre de usuario",
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
                controller: _nombre,
                decoration: InputDecoration(
                  hintText: "Ingrese su nombre",
                  labelText: "Nombre",
                  suffixIcon: Icon(
                    Icons.man
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
                controller: _apellido,
                decoration: InputDecoration(
                  hintText: "Ingrese su apellido",
                  labelText: "Apellido",
                  suffixIcon: Icon(
                    Icons.man
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
                controller: _correo,
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
                controller: _contrasena,
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
                  obscureText: true
              ),
              Divider(
                height: 10,
              ),
              SizedBox(
                width: 120,
                child: FloatingActionButton(
                  hoverColor: Colors.greenAccent[200],
                  onPressed: () async {
                    addUsers(_usuario.text.trim(), _nombre.text.trim(), _apellido.text.trim(), _correo.text.trim(), _contrasena.text.trim());
                  },
                  backgroundColor: Colors.red[200],
                  child: Text('Registrar',
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
              )
            ],
          )
        ],
      ),
    );
  }
}
