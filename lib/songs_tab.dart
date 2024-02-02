// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'song_detail_tab.dart';
import 'utils.dart';
import 'widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

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

  Widget _listBuilder(BuildContext context) {
    //return Container();

    // Show a slightly different color palette. Show poppy-ier colors on iOS
    // due to lighter contrasting bars and tone it down on Android.

    return SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Card(
                  child: Text("Prueba"),
                )
              ],
            )
          ],
        ));
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
      drawer: widget.androidDrawer,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 190,
                child: FilledButton(
                    child: const Text('Sugerir',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center),
                    onPressed: () {}),
              ),
              Padding(padding: EdgeInsets.all(30.0))
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 190,
                child: FilledButton(
                    child: const Text('Combinación',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center),
                    onPressed: () {}),
              ),
              Padding(padding: EdgeInsets.all(30.0))
            ],
          ),
        ],
      ),
    );
  }

  /*Widget _buildIos(BuildContext context) {
    return CustomScrollView(
      slivers: [
        Padding(padding: EdgeInsets.zero),
        CupertinoSliverRefreshControl(
          onRefresh: _refreshData,
        ),
        SliverBu
      ],
    );
  }*/

  @override
  Widget build(context) {
    return _buildAndroid(context);
  }
}
