import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_design/src/pages/register.dart';

class InvalidEmailFunc extends StatefulWidget {
  const InvalidEmailFunc({super.key});

  @override
  State<InvalidEmailFunc> createState() => _InvalidEmailFuncState();
}

@override


class _InvalidEmailFuncState extends State<InvalidEmailFunc> with SingleTickerProviderStateMixin {
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

  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('images/principal_background.jpg'),
                  ),
                ),
              ]),
              Text(
                '¡CORREO INCORRECTO!',
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
