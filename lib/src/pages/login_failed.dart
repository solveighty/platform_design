import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_design/src/pages/login.dart';

class LoginFailed extends StatefulWidget {
  const LoginFailed({super.key});

  @override
  State<LoginFailed> createState() => _LoginFailedState();
}

class _LoginFailedState extends State<LoginFailed>
    with SingleTickerProviderStateMixin {
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
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
              radius: 80,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('images/principal_background.jpg'),
            ),
          ]),
          Text(
            '¡CREDENCIALES INCORRECTAS!',
            style: TextStyle(
                fontFamily: 'Blacknorthdemo',
                fontSize: 30.0,
                color: Colors.black),
          ),
        ],
      )),
    );
  }
}
