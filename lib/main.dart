import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? token;
  String? notiData;
  String? notiSource;

  Future<void> initFirebase() async {
    await FirebaseMessaging.instance.requestPermission();
    token = await FirebaseMessaging.instance.getToken();
    setState(() {});

    FirebaseMessaging.onMessage.listen((message) {
      log(message.data.toString(), name: "FCM");
      notiData =
          '${message.notification?.title}\n${message.notification?.body}';
      notiSource = 'FCM';
      setState(() {});
      // showNotificationWithDefaultSound(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log(message.data.toString(), name: "FCM");
      notiData =
          '${message.notification?.title}\n${message.notification?.body}';
      notiSource = 'FCM';
      setState(() {});
    });
    //  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> showNotificationWithDefaultSound(RemoteMessage message) async {
    final int idNotify = int.tryParse(message.messageId ?? "0") ?? 0;
    final String? title =
        message.notification?.title ?? message.data['Title'] as String?;
    final String? body =
        message.notification?.body ?? message.data['Body'] as String?;
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      title ?? "",
      title ?? "",
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().show(
      idNotify,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void initJpush() {}

  @override
  void initState() {
    initFirebase();
    initJpush();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Copyable(
                title: "FCM Token",
                content: token,
              ),
              const Divider(),
              Copyable(content: notiData, title: notiSource ?? 'None'),
            ],
          ),
        ),
      ),
    );
  }
}

class Copyable extends StatelessWidget {
  const Copyable({
    super.key,
    required this.content,
    required this.title,
  });
  final String title;
  final String? content;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (content == null) return;
          Clipboard.setData(ClipboardData(text: content!));
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Copied $title')));
        },
        child: Text('$title:$content'));
  }
}
