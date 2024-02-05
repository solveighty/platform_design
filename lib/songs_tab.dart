// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:platform_design/src/pages/login.dart';
import 'package:platform_design/src/pages/startpage.dart';
import 'utils.dart';
import 'package:http/http.dart' as http;

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class SongsTab extends StatefulWidget {
  static const title = 'Menú Principal';
  static const androidIcon = Icon(Icons.music_note);
  static const iosIcon = Icon(CupertinoIcons.music_note);

  const SongsTab({super.key, this.androidDrawer});

  final Widget? androidDrawer;

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  static const _itemsLength = 50;
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _user2 = const types.User(id: 'i192039-a484-4a89-ae75-a22bf8d6f3ac');
  bool _isEnabled = true;

  void _toggleEnabled() {
    sendSugerir();
    setState(() {
      _isEnabled = !_isEnabled;
    });
  }

  void sendSugerir() {
    final sugerirMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "¿Cuál prenda o conjunto me sugieres para el día de hoy?",
    );
    _addMessage(sugerirMessage);
    sendPrompt();
  }

  void sendUserPrompt(String message) async {
    var url = Uri.parse('https://asistentedemoda.loophole.site/api/generate');
    String nombre = 'Andrew';
    Map params = {'model': 'moda', 'prompt': '$message', 'stream': false};
    var body = json.encode(params);
    // make http post request
    var response = await http.post(url, body: body);
    final text = jsonDecode(response.body) as Map<String, dynamic>;

    final promptMessage = types.TextMessage(
      author: _user2,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: '${text['response']}',
    );
    _addMessage(promptMessage);
  }

  void sendPrompt() async {
    var url = Uri.parse('https://asistentedemoda.loophole.site/api/generate');
    String nombre = 'Andrew';
    Map params = {
      'model': 'moda',
      'prompt': 'Hola, me llamo $nombre',
      'stream': false
    };
    var body = json.encode(params);
    // make http post request
    var response = await http.post(url, body: body);
    final text = jsonDecode(response.body) as Map<String, dynamic>;

    final promptMessage = types.TextMessage(
      author: _user2,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: '${text['response']}',
    );
    _addMessage(promptMessage);
  }

  void sendCombinacion() {
    final sugerirMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "",
    );
    _addMessage(sugerirMessage);
  }

  late List<MaterialColor> colors;
  late List<String> songNames;

  @override
  void initState() {
    _setData();
    super.initState();
  }

  void _setData() {
    colors = getRandomColors(_itemsLength);
    songNames = getRandomNames(_itemsLength);
  }

  Future<void> _refreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => setState(() => _setData()),
    );
  }

  void _togglePlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    } else {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    }

    // This rebuilds the application. This should obviously never be
    // done in a real app but it's done here since this app
    // unrealistically toggles the current platform for demonstration
    // purposes.
    WidgetsBinding.instance.reassembleApplication();
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are different items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            SongsTab.title,
            style: TextStyle(fontSize: 25),
          ),
        ),
        drawer: Drawer(
          child: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Cerrar Sesión"),
                  subtitle: Text("Salir de la cuenta"),
                  onTap: () async {
                    bool confirmLogout = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Cerrar Sesión"),
                          content: Text("¿Estás seguro de que deseas cerrar sesión?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // No cerrar sesión
                              },
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirmar cerrar sesión
                              },
                              child: Text("Cerrar Sesión"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmLogout != null && confirmLogout) {
                      try {
                        await FirebaseAuth.instance.signOut();
                        // Redirigir a la pantalla de inicio de sesión después de cerrar sesión
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => StartPageMonitoring()),
                              (Route<dynamic> route) => false,
                        );
                      } catch (e) {
                        print("Error al cerrar sesión: $e");
                        // Manejar el error (puedes mostrar un mensaje de error al usuario)
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        body: Chat(
          bubbleBuilder: _bubbleBuilder,
          showUserAvatars: true,
          showUserNames: true,
          theme: const DefaultChatTheme(backgroundColor: Colors.black54),
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                      width: 180,
                      child: FilledButton(
                          child: const Text('Sugerir',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                              textAlign: TextAlign.center),
                          onPressed: _isEnabled
                              ? _toggleEnabled
                              : null) // _isEnabled ? _toggleEnabled : null),
                      ),
                  Padding(padding: EdgeInsets.all(0.0))
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 180,
                    child: FilledButton(
                        child: const Text('Combinación',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return SizedBox(
                                    height: 400,
                                    child: Padding(
                                      padding: EdgeInsets.all(25.0),
                                      child: ListView(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Elije una prenda",
                                                  style: TextStyle(
                                                      fontSize: 23.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ])
                                        ],
                                      ),
                                    ));
                              });
                        }),
                  ),
                  Padding(padding: EdgeInsets.all(0.0))
                ],
              ),
            ],
          ),
        ]);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addMessage2(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    _addMessage(textMessage);
    sendUserPrompt(message.text);
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) =>
      Bubble(
        child: child,
        color: _user.id != message.author.id ||
                message.type == types.MessageType.image
            ? const Color(0xfff5f5f7)
            : const Color(0xff6f61e8),
        margin: nextMessageInGroup
            ? const BubbleEdges.symmetric(horizontal: 6)
            : null,
        nip: nextMessageInGroup
            ? BubbleNip.no
            : _user.id != message.author.id
                ? BubbleNip.leftBottom
                : BubbleNip.rightBottom,
      );

  @override
  Widget build(context) {
    return _buildAndroid(context);
  }
}
