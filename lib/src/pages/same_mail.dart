import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_design/src/pages/register.dart';

class SameMailFunc extends StatefulWidget {
  const SameMailFunc({super.key});

  @override
  State<SameMailFunc> createState() => _SameMailFuncState();
}

class _SameMailFuncState extends State<SameMailFunc> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const Register()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

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
            '¡CORREO EN USO!',
            style: TextStyle(
                fontFamily: 'Blacknorthdemo',
                fontSize: 50.0,
                color: Colors.black),
          ),
        ],
      )),
    );
  }
}
