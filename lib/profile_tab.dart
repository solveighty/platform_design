// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsImg(
                                  imagePath: _images[index].imagePath,
                                  nombrePrenda: _images[index].nombrePrenda,
                                  colorPrenda: _images[index].colorPrenda,
                                  descripcionPrenda:
                                      _images[index].descripcionPrenda)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: AssetImage(_images[index].imagePath),
                              fit: BoxFit.cover)),
                    ),
                  );
                },
                itemCount: _images.length,
              ),
            ))
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because on iOS, the settings tab is nested inside of
  // the profile tab as a button in the nav bar.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: _buildBody(context),
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
      child: _buildBody(context),
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
