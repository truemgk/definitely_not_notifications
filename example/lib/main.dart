import 'package:bot_toast/bot_toast.dart';
import 'package:definitely_not_notifications/definitely_not_notifications.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notifier.setup(
    appName: 'definitely_not_notifications_example'
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff416ff4),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Color(0xffF7F9FB),
        dividerColor: Colors.grey.withOpacity(0.3),
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: HomePage(),
    );
  }
}
