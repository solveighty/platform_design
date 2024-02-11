// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_design/request_data.dart';
import 'package:platform_design/src/pages/google_auth.dart';
import 'package:platform_design/utils.dart';

class NewsTab extends StatefulWidget {
  static const title = 'Añadir';
  static const androidIcon = Icon(Icons.camera_alt);
  static const iosIcon = Icon(CupertinoIcons.photo_camera);

  const NewsTab({Key? key}) : super(key: key);

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _checkCameraPermission();
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      await Permission.camera.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile picture = await _controller.takePicture();
      await _showSavePhotoDialog(context, picture);
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  Future<void> _showSavePhotoDialog(BuildContext context, XFile picture) async {
    String itemsIndex = await ImageStore.getLastIndex();
    String? imgBase64;
    List<int> bytes = SendToRest.readBytes(picture.path);
    String? clotheTitle;
    String? clotheType;
    List<String>? colorsList;
    ImageProvider imgAfter =
        NetworkImage("https://static.thenounproject.com/png/82078-200.png");

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '¿Quieres guardar la foto?',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: SendToRest.sendToRest(bytes),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error loading image');
                    } else {
                      Uint8List bytesDecoded =
                          base64Decode("${snapshot.data['data']!}");
                      ImageProvider imageProvider = MemoryImage(bytesDecoded);
                      imgAfter = MemoryImage(bytesDecoded);
                      imgBase64 = snapshot.data['data'];
                      clotheTitle = snapshot.data['title'];
                      clotheType = snapshot.data['type'];
                      colorsList = List<String>.from(snapshot.data['colors']);
                      return Image(image: imageProvider);
                    }
                  },
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: DefaultAccentColor.accentPressed),
                    onPressed: () async {
                      // Upload to Firestore

                      Navigator.of(context).pop();
                      showModalBottomSheet(
                          backgroundColor: DefaultAccentColor.defaultBackground,
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                                child: Padding(
                              padding: EdgeInsets.all(25.0),
                              child: ListView(
                                children: [
                                  Text(
                                    "Ajusta las características",
                                    style: TextStyle(
                                        color: DefaultAccentColor.textColor,
                                        fontSize: 23.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 20)),
                                  Image(
                                    image: imgAfter,
                                    height: 200,
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 20)),
                                  TextField(
                                    style: TextStyle(
                                        color: DefaultAccentColor.textColor),
                                    controller: TextEditingController(
                                        text: "$clotheTitle"),
                                    decoration: InputDecoration(
                                      labelText: 'Nombre de la prenda',
                                      prefixIcon: Icon(
                                        Icons.add,
                                        color: DefaultAccentColor.textColor,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 20)),
                                  TextField(
                                    style: TextStyle(
                                        color: DefaultAccentColor.textColor),
                                    controller: TextEditingController(
                                        text: "$clotheType"),
                                    decoration: InputDecoration(
                                      labelText: 'Tipo de la prenda',
                                      prefixIcon: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: DefaultAccentColor.textColor,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 15)),
                                  Text(
                                    "Colores",
                                    style: TextStyle(
                                        color: DefaultAccentColor.textColor),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 5)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: Icon(Icons.close,
                                            color: Colors.white, size: 20),
                                        label: Text(
                                          "negro",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.black),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5)),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: Icon(Icons.close,
                                            color: Colors.white, size: 20),
                                        label: Text(
                                          "azul",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                      ),
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            size: 30,
                                          ))
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 150)),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      DefaultAccentColor
                                                          .accentPressed),
                                              child: Text(
                                                "Cancelar",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10)),
                                      Expanded(
                                          child: FilledButton(
                                              onPressed: () async {
                                                if (UserController
                                                    .isSignedInWithGoogle) {
                                                  final docRef =
                                                      FirebaseFirestore.instance
                                                          .collection('images')
                                                          .doc(UserController
                                                              .userId)
                                                          .set({
                                                    '$itemsIndex': {
                                                      'base64img': imgBase64,
                                                      'lastUsed': 'Ayer',
                                                      'title': '$clotheTitle',
                                                      'type': '$clotheType',
                                                      'colors': colorsList
                                                    }
                                                  }, SetOptions(merge: true));
                                                } else {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('images')
                                                      .doc(FirebaseAuthService
                                                          .userId)
                                                      .set({
                                                    '2': {
                                                      'fileName':
                                                          '${picture.path.split('/').last}'
                                                    }
                                                  });
                                                }
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Prenda guardada exitosamente");
                                                Navigator.pop(context);
                                              },
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      DefaultAccentColor
                                                          .accentPressed),
                                              child: Text(
                                                "Aceptar",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )))
                                    ],
                                  )
                                ],
                              ),
                            ));
                          });
                    },
                    child: Text('Aceptar'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: DefaultAccentColor.accentPressed),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tomar otra foto"),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> _showSuggestionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sugerencia'),
          content: Text(
              'Al momento de tomar la foto, asegúrate de estar en un lugar con buena iluminación.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
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
              'Añadir',
              style: TextStyle(color: DefaultAccentColor.textColor),
            ),
            IconButton(
              onPressed: () {
                _showSuggestionDialog(context);
              },
              icon: Icon(
                Icons.info,
                color: DefaultAccentColor.textColor,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 55), // Camera Button
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () async {
                try {
                  await _takePicture();
                } catch (e) {
                  print(e);
                }
              },
              child: Icon(
                Icons.camera_alt_rounded,
                size: 50,
                color: DefaultAccentColor.accentPressed,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class ImageStore {
  static Future<String> getLastIndex() async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection("images")
          .doc(UserController.userId);
      DocumentSnapshot snapshot = await userDocRef.get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      int index = int.parse(data.entries.last.key);
      index++;
      return index.toString();
    } catch (e) {
      print(e);
      return "0";
    }
  }
}
