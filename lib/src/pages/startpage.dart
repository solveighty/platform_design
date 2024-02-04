import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/src/pages/login.dart';
import 'package:platform_design/src/pages/register.dart';

class StartPageMonitoring extends StatefulWidget {
  StartPageMonitoring({super.key});

  @override
  State<StartPageMonitoring> createState() => _StartPageMonitoringState();
}

class _StartPageMonitoringState extends State<StartPageMonitoring> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 115,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      AssetImage('images/principal_background.jpg'),
                ),
                Text(
                  'ASISTENTE FASHION',
                  style: TextStyle(
                    fontFamily: 'Blacknorthdemo',
                    fontSize: 45.0,
                      color: Colors.black),
                ),
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    hoverColor: Colors.greenAccent[200],
                    onPressed: () {
                      final route =
                          MaterialPageRoute(builder: (context) => LoginPage());
                      Navigator.push(context, route);
                    },
                    backgroundColor: Colors.red[200],
                    child: Text(
                      'Ingresar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontFamily: 'Moonchild'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    hoverColor: Colors.greenAccent[200],
                    onPressed: () {
                      final route =
                          MaterialPageRoute(builder: (context) => Register());
                      Navigator.push(context, route);
                    },
                    backgroundColor: Colors.red[200],
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontFamily: 'Moonchild'),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
