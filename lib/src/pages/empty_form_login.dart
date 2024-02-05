import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_design/src/pages/login.dart';

class EmptyFormLogin extends StatefulWidget {
  const EmptyFormLogin({super.key});

  @override
  State<EmptyFormLogin> createState() => _EmptyFormLoginState();
}

class _EmptyFormLoginState extends State<EmptyFormLogin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
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
                '¡LLENE LOS DATOS!',
                style: TextStyle(
                    fontFamily: 'Blacknorthdemo',
                    fontSize: 40.0,
                    color: Colors.black),
              ),
            ],
          )),
    );
  }
}
