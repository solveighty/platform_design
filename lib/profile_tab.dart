// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_design/src/pages/google_auth.dart';
import 'package:platform_design/utils.dart';
import 'details.dart';

import 'settings_tab.dart';
import 'widgets.dart';

List<ImageDetails> _images = [
  ImageDetails(
      imagePath: 'images/img1.jpeg',
      nombrePrenda: "Staryuuki",
      colorPrenda: ["rojo", "amarillo", "blanco"],
      descripcionPrenda: "una prenda demasiado cómoda"),
  ImageDetails(
      imagePath: 'images/ai_avatar.png',
      nombrePrenda: "CrystalMolly",
      colorPrenda: ["rojo", "amarillo", "blanco"],
      descripcionPrenda: "una prenda demasiado cómoda"),
  ImageDetails(
      imagePath: 'images/principal_background.jpg',
      nombrePrenda: "RuneBee",
      colorPrenda: ["rojo", "amarillo", "blanco"],
      descripcionPrenda: "una prenda demasiado cómoda")
];

class ProfileTab extends StatelessWidget {
  static const title = 'Galeria';
  static const androidIcon = Icon(Icons.person);
  static const iosIcon = Icon(CupertinoIcons.profile_circled);

  const ProfileTab({super.key});

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
              onPressed: () {
                ImagesStorage.getImagesCollection();
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImages(BuildContext context) {

    return StreamBuilder<List<String>>(
      stream: ImagesStorage.getImagesCollection(),
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
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          child: ListView(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image(
                                        image: img,
                                        height: 200,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 100)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "",
                                            style: TextStyle(
                                                color: DefaultAccentColor
                                                    .textColor,
                                            fontSize: 20),
                                          )
                                        ],
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
        } else if (snapshot.hasError) {
          return Text('Error loading images');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  // ===========================================================================
  // Non-shared code below because on iOS, the settings tab is nested inside of
  // the profile tab as a button in the nav bar.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
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
      body: _buildImages(context),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: SettingsTab.iosIcon,
          onPressed: () {
            // This pushes the settings page as a full page modal dialog on top
            // of the tab bar and everything.
            Navigator.of(context, rootNavigator: true).push<void>(
              CupertinoPageRoute(
                title: SettingsTab.title,
                fullscreenDialog: true,
                builder: (context) => const SettingsTab(),
              ),
            );
          },
        ),
      ),
      child: _buildImages(context),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}

class PreferenceCard extends StatelessWidget {
  const PreferenceCard({
    required this.header,
    required this.content,
    required this.preferenceChoices,
    super.key,
  });

  final String header;
  final String content;
  final List<String> preferenceChoices;

  @override
  Widget build(context) {
    return PressableCard(
      color: Colors.green,
      flattenAnimation: const AlwaysStoppedAnimation(0),
      child: Stack(
        children: [
          SizedBox(
            height: 120,
            width: 250,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black12,
              height: 40,
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                header,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        showChoices(context, preferenceChoices);
      },
    );
  }
}

class LogOutButton extends StatelessWidget {
  static const _logoutMessage = Text(
      "You can't actually log out! This is just a demo of how alerts work.");

  const LogOutButton({super.key});

  // ===========================================================================
  // Non-shared code below because this tab shows different interfaces. On
  // Android, it's showing an alert dialog with 2 buttons and on iOS,
  // it's showing an action sheet with 3 choices.
  //
  // This is a design choice and you may want to do something different in your
  // app.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return ElevatedButton(
      child: const Text('LOG OUT', style: TextStyle(color: Colors.red)),
      onPressed: () {
        // You should do something with the result of the dialog prompt in a
        // real app but this is just a demo.
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Log out?'),
              content: _logoutMessage,
              actions: [
                TextButton(
                  child: const Text('Got it'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.destructiveRed,
      child: const Text('Log out'),
      onPressed: () {
        // You should do something with the result of the action sheet prompt
        // in a real app but this is just a demo.
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: const Text('Log out?'),
              message: _logoutMessage,
              actions: [
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reprogram the night man'),
                ),
                CupertinoActionSheetAction(
                  child: const Text('Got it'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
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
  static Stream<List<String>> getImagesCollection() {
    final userDocRef = FirebaseFirestore.instance
        .collection("images")
        .doc(UserController.userId);

    return userDocRef.snapshots().map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> base64ImagesDynamic = [];
      data.forEach((key, value) {
        base64ImagesDynamic.add(value['base64img']);
      });
      print(base64ImagesDynamic);

      // Explicitly convert each dynamic element to a string
      List<String> base64Images =
          base64ImagesDynamic.map((image) => image.toString()).toList();
      return base64Images;
    });
  }
}
