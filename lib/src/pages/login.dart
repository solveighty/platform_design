import 'package:aura_box/aura_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform_design/main.dart';
import 'package:platform_design/src/pages/register.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:platform_design/utils.dart';

import '../../news_tab.dart';
import '../../profile_tab.dart';
import '../../songs_tab.dart';
import 'google_auth.dart';

Widget _buildIosHomePage(BuildContext context) {
  return CupertinoTabScaffold(
    tabBar: CupertinoTabBar(
      items: const [
        BottomNavigationBarItem(
          label: SongsTab.title,
          icon: Icon(Icons.assistant_outlined),
        ),
        BottomNavigationBarItem(
          label: NewsTab.title,
          icon: Icon(Icons.add_a_photo_outlined),
        ),
        BottomNavigationBarItem(
          label: ProfileTab.title,
          icon: Icon(Icons.auto_awesome_mosaic_rounded),
        ),
      ],
    ),
    tabBuilder: (context, index) {
      assert(index <= 2 && index >= 0, 'Unexpected tab index: $index');
      switch (index) {
        case 0:
          return CupertinoTabView(
            defaultTitle: SongsTab.title,
            builder: (context) => SongsTab(key: songsTabKey),
          );
        case 1:
          return CupertinoTabView(
            defaultTitle: NewsTab.title,
            builder: (context) => const NewsTab(),
          );
        case 2:
          return CupertinoTabView(
            defaultTitle: ProfileTab.title,
            builder: (context) => const ProfileTab(),
          );
        default:
          return SizedBox.shrink();
      }
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _correoController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();

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
                "INGRESO",
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
            Padding(padding: EdgeInsets.all(20)),
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
              controller: _correoController,
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
              onPressed: _signIn,
              child: Text(
                'INGRESAR',
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
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await UserController.loginWithGoogle();
                  if (user != null && mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => _buildIosHomePage(context)),
                        (Route<dynamic> route) => false);
                  }
                } on FirebaseAuthException catch (error) {
                  print(error.message);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    error.message ?? "Something went wrong",
                  )));
                } catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    'No has seleccionado ninguna cuenta',
                  )));
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.red[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'images/google-icon.svg',
                    height: 24.0,
                    width: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'INGRESO CON GOOGLE',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: Text(
                '¿No tienes una cuenta? Regístrate',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    String email = _correoController.text;
    String password = _contrasenaController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Llene los datos.'),
        ),
      );
      return;
    }

    try {
      User? user =
          await _auth.signInWithEmailAndPassword(email, password, context);

      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => _buildIosHomePage(context)),
            (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El correo electrónico no está registrado.'),
        ),
      );
    }
  }
}
