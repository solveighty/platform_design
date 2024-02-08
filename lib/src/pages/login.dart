import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/main.dart';
import 'package:platform_design/src/pages/empty_form_login.dart';
import 'package:platform_design/src/pages/register.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _correoController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        title: Text('Ingreso'),
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
              onPressed: () async {},
              child: Text(
                'INGRESAR',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
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
}
