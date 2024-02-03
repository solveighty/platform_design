import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_design/src/pages/register.dart';

class EmptyFormRegister extends StatefulWidget {
  const EmptyFormRegister({super.key});

  @override
  State<EmptyFormRegister> createState() => _EmptyFormRegisterState();
}

class _EmptyFormRegisterState extends State<EmptyFormRegister> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersive
    );
    Future.delayed(Duration(seconds: 2), (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const Register()));
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values
    );
    super.dispose();
  }
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 115,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/principal_background.jpg'),
              ),
              Text(
                '¡LLENE LOS DATOS!',
                style: TextStyle(
                  fontFamily: 'Blacknorthdemo',
                  fontSize: 50.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
