// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late StreamSubscription<User?> _authStateChangesSubscription;
  ValueNotifier<bool> _isEnabled = ValueNotifier<bool>(true);

  void toggleEnabled() {
    _isEnabled.value = !_isEnabled.value;
  }


  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _authStateChangesSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          UserController.setUser(user);
        });
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
    List<String>? RGBA;
    List<Color>? colors;
    int index2;

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
                      toggleEnabled();
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      toggleEnabled();
                      return Text('Error loading image');
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        toggleEnabled();
                      });
                      Uint8List bytesDecoded =
                          base64Decode("${snapshot.data['data']!}");
                      ImageProvider imageProvider = MemoryImage(bytesDecoded);
                      imgAfter = MemoryImage(bytesDecoded);
                      imgBase64 = snapshot.data['data'];
                      clotheTitle = snapshot.data['title'];
                      clotheType = snapshot.data['type'];
                      colorsList =
                          List<String>.from(snapshot.data['colors']) ?? [];
                      RGBA = List<String>.from(snapshot.data['RGBA']) ?? [];
                      try {
                        colors = RGBA?.map((rgbaString) {
                          var rgbaValues = rgbaString.substring(
                              5, rgbaString.length - 1).split(', ');
                          return Color.fromRGBO(
                              int.parse(rgbaValues[0]),
                              int.parse(rgbaValues[1]),
                              int.parse(rgbaValues[2]),
                              double.parse(rgbaValues[3])
                          );
                        }).toList();
                      }catch(e){
                        Fluttertoast.showToast(msg: "No se pudieron determinar los colores de la prenda");
                        colors = RGBA?.map((rgbaString) {
                          var rgbaValues = rgbaString.substring(
                              5, rgbaString.length - 1).split(', ');
                          return Color.fromRGBO(
                              0,
                              0,
                              0,
                              1
                          );
                        }).toList();
                      }
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _isEnabled,
                    builder: (BuildContext context, bool isEnabled, Widget? child) {
                      return FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: DefaultAccentColor.accentPressed),
                        onPressed: isEnabled ? () async {
                          // Upload to Firestore

                          Navigator.of(context).pop();
                          showModalBottomSheet(
                              enableDrag: true,
                              showDragHandle: true,
                              backgroundColor: DefaultAccentColor.defaultBackground,
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 25, right: 25),
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
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 4.0,
                                                  children: colorsList!.map((e) {
                                                    int index = colorsList?.indexOf(e) ?? 0;
                                                    return TextButton.icon(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.close,
                                                          color: Colors.white,
                                                          size: 20),
                                                      label: Text(
                                                        "${e.toString()}",
                                                        style: TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                      style: FilledButton.styleFrom(
                                                          backgroundColor:
                                                          colors?[index]),
                                                    );
                                                  }).toList(),
                                                ),
                                                IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      Icons.add_circle_outline,
                                                      size: 30,
                                                    ))
                                              ],
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.only(bottom: 20)),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: FilledButton(
                                                      onPressed: () async {
                                                        if (UserController
                                                            .isSignedInWithGoogle) {
                                                          FirebaseFirestore.instance
                                                              .collection('images')
                                                              .doc(
                                                              UserController.userId)
                                                              .set({
                                                            '$itemsIndex': {
                                                              'base64img': imgBase64,
                                                              'lastUsed': 'Ayer',
                                                              'title': '$clotheTitle',
                                                              'type': '$clotheType',
                                                              'colors': colorsList,
                                                              'RGBA': RGBA
                                                            }
                                                          }, SetOptions(merge: true));
                                                        } else {
                                                          FirebaseFirestore.instance
                                                              .collection('images')
                                                              .doc(
                                                              FirebaseAuthService.userId)
                                                              .set({
                                                            '$itemsIndex': {
                                                              'base64img': imgBase64,
                                                              'lastUsed': 'Ayer',
                                                              'title': '$clotheTitle',
                                                              'type': '$clotheType',
                                                              'colors': colorsList,
                                                              'RGBA': RGBA
                                                            }
                                                          }, SetOptions(merge: true));
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
                        } : null,
                        child: Text('Aceptar'),
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isEnabled,
                    builder: (BuildContext context, bool isEnabled, Widget? child) {
                      return FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: DefaultAccentColor.accentPressed),
                        onPressed: isEnabled ? (){Navigator.pop(context);} : null,
                        child: Text("Tomar otra foto"),
                      );
                    },
                  )

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: MaterialButton(
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
            )
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
