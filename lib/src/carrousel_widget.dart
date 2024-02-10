import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:platform_design/src/pages/login.dart';
import 'package:platform_design/utils.dart';

class Carrousel extends StatefulWidget {
  const Carrousel({super.key});

  @override
  State<Carrousel> createState() => _CarrouselState();
}

class _CarrouselState extends State<Carrousel> {
  @override
  Widget build(BuildContext context) {
    Widget title = const Text(
      textAlign: TextAlign.center,
      'EMPIEZA AHORA',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 50,
        color: Colors.white,
        height: 1,
        letterSpacing: -1,
      ),
    );
    Widget btnStart = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, foregroundColor: Colors.white),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
            PageTransition(
                child: LoginPage(), type: PageTransitionType.size, alignment: Alignment.bottomCenter, duration: Duration(milliseconds: 700)),
            (Route<dynamic> route) => false);
      },
      child: Icon(Icons.arrow_forward_ios),
    );
    title = title
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
        .animate() // this wraps the previous Animate in another Animate
        .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
        .slide();
    btnStart = btnStart
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.tealAccent)
        .animate() // this wraps the previous Animate in another Animate
        .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
        .slide();
    return Scaffold(
        backgroundColor: Colors.black87,
        body: FlutterCarousel(
            options: CarouselOptions(
              padEnds: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(seconds: 1),
              height: MediaQuery.of(context).size.height,
              showIndicator: true,
              slideIndicator: CircularWaveSlideIndicator(),
            ),
            items: [
              Builder(
                builder: (BuildContext context) {
                  return Image(
                      isAntiAlias: true,
                      fit: BoxFit.fitHeight,
                      image: AssetImage('images/carrousel_1.png'));
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return Image(
                      isAntiAlias: true,
                      fit: BoxFit.fitHeight,
                      image: AssetImage('images/carrousel_2.png'));
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return Image(
                      isAntiAlias: true,
                      fit: BoxFit.fitHeight,
                      image: AssetImage('images/carrousel_3.png'));
                },
              ),
              Scaffold(
                backgroundColor: Colors.black87,
                floatingActionButton: btnStart,
                body: Center(
                  child: title,
                ),
              )
            ]));
  }
}
