// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_design/request_data.dart';
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
    ImageProvider? img;
    List<int> bytes = SendToRest.readBytes(picture.path);

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
                          base64Decode("${snapshot.data!}");
                      ImageProvider imageProvider = MemoryImage(bytesDecoded);
                      img = imageProvider;
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
                    style: FilledButton.styleFrom(backgroundColor: DefaultAccentColor.accentPressed),
                    onPressed: () {

                      Navigator.of(context).pop();
                    },
                    child: Text('Aceptar'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: DefaultAccentColor.accentPressed),
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
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Text('Añadir'),
            IconButton(
              onPressed: () {
                _showSuggestionDialog(context);
              },
              icon: Icon(Icons.info),
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
