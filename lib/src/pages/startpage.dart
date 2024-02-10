import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:platform_design/src/pages/login.dart';
import 'package:platform_design/src/pages/register.dart';
import 'package:platform_design/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StartPageMonitoring extends StatefulWidget {
  StartPageMonitoring({super.key});


  @override
  State<StartPageMonitoring> createState() => _StartPageMonitoringState();
}

class _StartPageMonitoringState extends State<StartPageMonitoring> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultAccentColor.defaultBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 115,
                  backgroundColor: DefaultAccentColor.defaultBackground,
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
                CircleAvatar(
                  radius: 115,
                  backgroundColor: Colors.grey[700],
                  backgroundImage:
                  AssetImage('images/principal_background2.jpeg'),
                ),
                SizedBox(height: 100.0),
                ElevatedButton(
                  onPressed: () async {
                    final route = MaterialPageRoute(
                        builder: (context) => LoginPage());
                    Navigator.push(context, route);
                  },
                  child: Text(
                    'INGRESAR',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 150),
                    backgroundColor: DefaultAccentColor.accentPressed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final route = MaterialPageRoute(
                        builder: (context) => Register());
                    Navigator.push(context, route);
                  },
                  child: Text(
                    'REGISTRAR',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 150),
                    backgroundColor: DefaultAccentColor.accentPressed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
