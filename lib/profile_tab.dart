// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform_design/songs_tab.dart';
import 'package:platform_design/src/pages/google_auth.dart';
import 'package:platform_design/utils.dart';
import 'details.dart';

import 'settings_tab.dart';
import 'widgets.dart';

class ProfileTab extends StatefulWidget {
  static const title = 'Galeria';
  static const androidIcon = Icon(Icons.person);
  static const iosIcon = Icon(CupertinoIcons.profile_circled);

  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String title = 'loading...';
  double position = 0.0;
  String type = 'loading...';
  String lastUsed = 'loading...';
  List<String> colors = [];
  List<String>? RGBA;
  List<Color>? colorsD;

  late StreamSubscription<User?> _authStateChangesSubscription;

  @override
  void initState() {
    super.initState();
    _authStateChangesSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      UserController.setUser(user);
    });
  }

  Future<void> _showSuggestionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DefaultAccentColor.defaultBackground,
          title: Text(
            'Sugerencia',
            style: TextStyle(color: DefaultAccentColor.textColor),
          ),
          content: Text(
            'Aquí se guardarán todas las prendas que posees, junto con información detallada.',
            style: TextStyle(color: DefaultAccentColor.textColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: DefaultAccentColor.defaultBackground,
        appBar: AppBar(
          backgroundColor: DefaultAccentColor.defaultBackground,
          centerTitle: true,
          title: Row(
            children: [
              Text(
                'Galería',
                style: TextStyle(color: DefaultAccentColor.textColor),
              ),
              IconButton(
                onPressed: () {
                  _showSuggestionDialog(context);
                },
                icon: Icon(Icons.info, color: DefaultAccentColor.textColor),
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<String>>(
          stream: UserController.isSignedInWithGoogle
              ? FirestoreImg.getImagesCollection(UserController.userId)
              : FirestoreImg.getImagesCollection(FirebaseAuthService.userId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> base64Strings = snapshot.data!;
              return Padding(padding: EdgeInsets.only(left: 20, right: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: base64Strings.length,
                itemBuilder: (context, index) {
                  Uint8List bytes = base64Decode(base64Strings[index]);
                  ImageProvider img = MemoryImage(bytes);
                  return RawMaterialButton(
                    onPressed: () async {
                      var getTile;
                      var getPosition;
                      var getType;
                      var getLastUsed;
                      List<String> colorsList;
                      List<dynamic> getRGBA;
                      List<dynamic> listDynamic;
                      if (UserController.isSignedInWithGoogle) {
                        getTile = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "title");
                        getPosition = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "position");
                        getType = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "type");
                        getLastUsed = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "lastUsed");
                        getRGBA = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "RGBA");
                        listDynamic = await FirestoreImg.getFirestoreInfo(
                            UserController.userId, index, "colors");
                        colorsList =
                            listDynamic.map((e) => e.toString()).toList();
                      } else {
                        getTile = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "title");
                        getPosition = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "position");
                        getType = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "type");
                        getLastUsed = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "lastUsed");
                        getRGBA = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "RGBA");
                        listDynamic = await FirestoreImg.getFirestoreInfo(
                            FirebaseAuthService.userId, index, "colors");
                        colorsList =
                            listDynamic.map((e) => e.toString()).toList();
                      }
                      setState(() {
                        title = getTile;
                        position = getPosition;
                        type = getType;
                        lastUsed = getLastUsed;
                        colors = colorsList;
                        RGBA = getRGBA.cast<String>();
                        try {
                          colorsD = RGBA?.map((rgbaString) {
                            var rgbaValues = rgbaString
                                .substring(5, rgbaString.length - 1)
                                .split(', ');
                            return Color.fromRGBO(
                                int.parse(rgbaValues[0]),
                                int.parse(rgbaValues[1]),
                                int.parse(rgbaValues[2]),
                                double.parse(rgbaValues[3]));
                          }).toList();
                        } catch (e) {
                          colorsD = RGBA?.map((rgbaString) {
                            var rgbaValues = rgbaString
                                .substring(5, rgbaString.length - 1)
                                .split(', ');
                            return Color.fromRGBO(0, 0, 0, 1);
                          }).toList();
                        }
                      });

                      showModalBottomSheet(
                          enableDrag: true,
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                            return ListView(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 40,
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        // Aligns the text to the start of the stack
                                        children: [
                                          Center(
                                            child: Text(
                                              "${title.toUpperCase()}",
                                              style: GoogleFonts.oswald(
                                                  color: Colors.black54,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            // Positions the button at the end of the stack
                                            child: Padding(
                                              padding:
                                              EdgeInsets.only(right: 10),
                                              child: IconButton(
                                                onPressed: () {
                                                  if (UserController
                                                      .isSignedInWithGoogle) {
                                                    FirestoreImg
                                                        .deleteFirestoreItem(
                                                        UserController
                                                            .userId,
                                                        index.toString());
                                                  } else {
                                                    FirestoreImg
                                                        .deleteFirestoreItem(
                                                        FirebaseAuthService
                                                            .userId,
                                                        index.toString());
                                                  }
                                                  Fluttertoast.showToast(
                                                      msg:
                                                      "Prenda eliminada exitosamente");
                                                  Navigator.pop(context);
                                                },
                                                icon:
                                                Icon(CupertinoIcons.trash),
                                                color: DefaultAccentColor
                                                    .defaultBackground,
                                                style: IconButton.styleFrom(
                                                    backgroundColor:
                                                    Colors.red[400]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 20)),
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Padding(
                                              padding:
                                              EdgeInsets.only(left: 20)),
                                          Container(
                                            child: Image(
                                              image: img,
                                              height: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: Offset(4, 8))
                                              ],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                              EdgeInsets.only(left: 20)),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 20),
                                                      width: 200,
                                                      alignment:
                                                      Alignment.topLeft,
                                                      child: Text(
                                                        "TIPO:",
                                                        style: GoogleFonts
                                                            .inriaSans(
                                                          color: Colors.black38,
                                                          fontSize: 17,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 50),
                                                      width: 200,
                                                      alignment:
                                                      Alignment.topLeft,
                                                      child: Text(
                                                        "${type.toUpperCase()}",
                                                        style:
                                                        GoogleFonts.nunito(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 20),
                                                      width: 200,
                                                      alignment:
                                                      Alignment.topLeft,
                                                      child: Text(
                                                        "ÚLTIMO USO:",
                                                        style: GoogleFonts
                                                            .inriaSans(
                                                          color: Colors.black38,
                                                          fontSize: 17,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 50, top: 15),
                                                      width: 200,
                                                      alignment:
                                                      Alignment.topLeft,
                                                      child: Text(
                                                        "${lastUsed.toUpperCase()}",
                                                        style:
                                                        GoogleFonts.nunito(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 40, left: 20)),
                                          Text(
                                            "Posición actual:".toUpperCase(),
                                            style: GoogleFonts.inriaSans(
                                              color: Colors.black38,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatefulBuilder(
                                      builder: (context, state) => Center(
                                        child: Slider(
                                          activeColor: DefaultAccentColor.accentPressed,
                                          value: position,
                                          min: 1.0,
                                          max: 6.0,
                                          divisions: 5,
                                          label: "Posición: ${position.round().toString()}",
                                          onChanged: (val) {
                                            state(() {
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 40, left: 20)),
                                          Text(
                                            "COLORES:",
                                            style: GoogleFonts.inriaSans(
                                              color: Colors.black38,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Padding(
                                                padding:
                                                EdgeInsets.only(left: 20)),
                                            Wrap(
                                              spacing: 8.0,
                                              runSpacing: 4.0,
                                              children: colorsList.map((e) {
                                                int cIndex =
                                                    colorsList.indexOf(e) ?? 0;
                                                return TextButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    "${e.toString()}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  style: FilledButton.styleFrom(
                                                      backgroundColor:
                                                      colorsD?[cIndex]),
                                                );
                                              }).toList(),
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              ],
                            );
                          });
                    },
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: Offset(2, 3))
                          ],
                          image: DecorationImage(image: img)),
                    ),
                  );
                },
              ));
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'No has registrado ninguna imagen',
                  style: TextStyle(color: Colors.black38),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class FirestoreImg {
  static Stream<List<String>> getImagesCollection(String? userId) {
    final userDocRef =
        FirebaseFirestore.instance.collection("images").doc(userId);

    return userDocRef.snapshots().map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> base64List = [];
      data.forEach((key, value) {
        base64List.add(value['base64img']);
      });
      List<String> base64Images =
          base64List.map((item) => item.toString()).toList();
      return base64Images;
    });
  }

  static getFirestoreInfo(String? userId, int index, String strvalue) async {
    final userDocRef =
        FirebaseFirestore.instance.collection("images").doc(userId);
    DocumentSnapshot snapshot = await userDocRef.get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data[index.toString()][strvalue];
  }

  static deleteFirestoreItem(String? userId, String fieldKey) async {
    final userDocRef =
        FirebaseFirestore.instance.collection("images").doc(userId);
    DocumentSnapshot snapshot = await userDocRef.get();

    await userDocRef.update({fieldKey: FieldValue.delete()});
  }
}
