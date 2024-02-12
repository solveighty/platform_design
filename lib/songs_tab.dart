// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform_design/profile_tab.dart';
import 'package:platform_design/src/pages/google_auth.dart';
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
  String title = 'loading...';


  late StreamSubscription<User?> _authStateChangesSubscription;

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

  void sendCombinacion(String title) {
    String highlightedTitle = '👚' + title + '👚';
    final sugerirMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "¿Con que podría combinar la siguiente prenda de ropa? \n\n $highlightedTitle",
    );
    _addMessage(sugerirMessage);
  }

  late List<MaterialColor> colors;
  late List<String> songNames;
  late User? _avatar;
  late String _profileImageUrl;

  @override
  void initState() {
    _setData();
    super.initState();
    _authStateChangesSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      UserController.setUser(user);
    });
  }

  void _setData() {
    colors = getRandomColors(_itemsLength);
    songNames = getRandomNames(_itemsLength);
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        backgroundColor: DefaultAccentColor.defaultBackground,
        appBar: AppBar(
          backgroundColor: DefaultAccentColor.defaultBackground,
          title: Text(
            SongsTab.title,
            style: TextStyle(fontSize: 25, color: DefaultAccentColor.textColor),
          ),
        ),
        drawer: Drawer(
          backgroundColor: DefaultAccentColor.defaultBackground,
          child: Drawer(
            backgroundColor: DefaultAccentColor.defaultBackground,
            child: ListView(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  child: ClipOval(
                    child: Image.network(
                      UserController.user?.photoURL ??
                          "https://www.shutterstock.com/image-vector/vector-flat-illustration-grayscale-avatar-600nw-2281862025.jpg",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Center(
                  child: Text(
                    UserController.user?.email ?? '',
                    style: TextStyle(color: DefaultAccentColor.textColor),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    "Cerrar Sesión",
                    style: TextStyle(color: DefaultAccentColor.textColor),
                  ),
                  subtitle: Text(
                    "Salir de la cuenta",
                    style: TextStyle(color: DefaultAccentColor.textColor),
                  ),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: DefaultAccentColor.defaultBackground,
                          title: Text("Cerrar Sesión",
                              style: TextStyle(
                                  color: DefaultAccentColor.textColor)),
                          content: Text(
                            "¿Estás seguro de que deseas cerrar sesión?",
                            style:
                                TextStyle(color: DefaultAccentColor.textColor),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // No cerrar sesión
                              },
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                    color: DefaultAccentColor.accentPressed),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await UserController.signOut();
                                await FirebaseAuth.instance.signOut();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StartPageMonitoring()),
                                      (Route<dynamic> route) => false);
                                }
                              },
                              child: Text(
                                "Cerrar Sesión",
                                style: TextStyle(
                                    color: DefaultAccentColor.accentPressed),
                              ),
                            ),
                          ],
                        );
                      },
                    );
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
          theme: DefaultChatTheme(
              backgroundColor: DefaultAccentColor.defaultBackground,
              inputBackgroundColor: DefaultAccentColor.defaultBackground,
              inputTextColor: DefaultAccentColor.defaultBackgroundDark),
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
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  DefaultAccentColor.accentPressed),
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
                        style: FilledButton.styleFrom(
                            backgroundColor: DefaultAccentColor.accentPressed),
                        child: const Text('Combinación',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center),
                        onPressed: () {
                          showModalBottomSheet(
                              enableDrag: true,
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        // Aligns the text to the start of the stack
                                        children: [
                                          Center(
                                            child: Text(
                                              "Selecciona un prenda",
                                              style: GoogleFonts.oswald(
                                                  color: Colors.black54,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StreamBuilder<List<String>>(
                                      stream: UserController
                                          .isSignedInWithGoogle
                                          ? ImagesStorage.getImagesCollection(
                                          UserController.userId)
                                          : ImagesStorage.getImagesCollection(
                                          FirebaseAuthService.userId),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          List<String> base64Strings =
                                          snapshot.data!;
                                          return Expanded(child: GridView.builder(
                                            shrinkWrap: true,
                                              gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3),
                                              itemCount: base64Strings.length,
                                              itemBuilder: (context, index) {
                                                Uint8List bytes = base64Decode(
                                                    base64Strings[index]);
                                                ImageProvider img =
                                                MemoryImage(bytes);
                                                return RawMaterialButton(
                                                  onPressed: () async {
                                                    var getTile;
                                                    if (UserController.isSignedInWithGoogle) {
                                                      getTile = await ImagesStorage.getFirestoreInfo(
                                                          UserController.userId, index, "title");
                                                    } else {
                                                      getTile = await ImagesStorage.getFirestoreInfo(
                                                          FirebaseAuthService.userId, index, "title");
                                                    }
                                                    setState(() {
                                                      title = getTile;
                                                    });

                                                    sendCombinacion(title);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                      image: DecorationImage(
                                                          image: img),
                                                    ),
                                                  ),
                                                );
                                              }));
                                        } else if (!snapshot.hasData) {
                                          return Center(
                                            child: Text(
                                              'No has registrado ninguna imagen',
                                              style: TextStyle(
                                                  color: Colors.black38),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    )

                                  ],
                                );
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
            ? Colors.white30
            : DefaultAccentColor.accentPressed,
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
