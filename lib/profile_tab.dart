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
              ? ImagesStorage.getImagesCollection(UserController.userId)
              : ImagesStorage.getImagesCollection(FirebaseAuthService.userId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> base64Strings = snapshot.data!;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: base64Strings.length,
                itemBuilder: (context, index) {
                  Uint8List bytes = base64Decode(base64Strings[index]);
                  ImageProvider img = MemoryImage(bytes);
                  return RawMaterialButton(
                    onPressed: () async {
                      var s = await ImagesStorage.getFirestoreInfo(
                          UserController.userId, index, "title");
                      setState(() {
                        title = s;
                      });

                      showModalBottomSheet(
                          enableDrag: true,
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              child: ListView(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, left: 20)),
                                      Center(
                                        child: Text(
                                          "${title.toUpperCase()}",
                                          style: GoogleFonts.oswald(
                                              color: Colors.black54,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.only(bottom: 20)),
                                      Row(
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
                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(4, 8))],
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [],
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: img)),
                    ),
                  );
                },
              );
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

class ImageDetails {
  late final String imagePath;
  late final String nombrePrenda;
  late final List<String> colorPrenda;
  late final String descripcionPrenda;

  ImageDetails(
      {required this.imagePath,
      required this.nombrePrenda,
      required this.colorPrenda,
      required this.descripcionPrenda});
}

class ImagesStorage {
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
}
