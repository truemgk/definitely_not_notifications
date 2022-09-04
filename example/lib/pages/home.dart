import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:definitely_not_notifications/definitely_not_notifications.dart';
import 'package:flutter/material.dart' hide MenuItem, Notification;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  Notification _exampleNotification = Notification(
    identifier: '_exampleNotification',
    title: "Laavi",
    body: "Cześć, twój fix nie działa do #1282",
    icon: 'C:/Users/Mateusz/Downloads/Logo Laavi.png',
    isCircle: true,
    hero: 'C:/Users/Mateusz/Downloads/1500x500.png',
    isInline: true,
    actions: [
      NotificationAction(
        text: 'Write a quick reply...',
      ),
    ],
  );

  @override
  void initState() {
    trayManager.addListener(this);
    super.initState();

    _initTray();

    _exampleNotification.onClose = (closeReason) {
      String log = 'onClose ${_exampleNotification.identifier} - $closeReason';
      print(log);
      BotToast.showText(text: log);
    };
    _exampleNotification.onClick = () {
      String log = 'onClick ${_exampleNotification.identifier}';
      print(log);
      BotToast.showText(text: log);
    };
    _exampleNotification.onClickAction = (actionIndex) {
      String log =
          'onClickAction ${_exampleNotification.identifier} - $actionIndex';
      print(log);
      BotToast.showText(text: log);
    };
  }

  void _initTray() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          label: 'show exampleNotification',
          onClick: (_) {
            notify(_exampleNotification);
          },
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Exit App',
          onClick: (_) async {
            await windowManager.destroy();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SizedBox(),
    );
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }
}
