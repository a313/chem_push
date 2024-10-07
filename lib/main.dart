import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? token;
  String? jPushID;
  String? notiData;
  String? notiSource;
  @override
  void initState() {
    // initFirebase();
    initJPush();
    super.initState();
  }

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

  void initJPush() {
    final jPush = JPush();
    jPush.requestRequiredPermission();
    jPush.setup(
      appKey: "af332ece8f8431e38f073dd2", //你自己应用的 AppKey
      channel: "developer-default",
      production: false,
      debug: true,
    );
    jPush.getRegistrationID().then((rid) {
      log("getRegistrationID: $rid", name: "JPush");
      setState(() {
        jPushID = rid;
      });
    });

    jPush.enableAutoWakeup(enable: true);
    jPush.addEventHandler(onReceiveNotification: (message) async {
      log("onReceiveNotification: $message", name: "JPush");
      notiSource = "JPush onReceiveNotification";
      notiData = message.toString();
      setState(() {});
    }, onOpenNotification: (message) async {
      log("onOpenNotification: $message", name: "JPush");
      notiSource = "JPush onOpenNotification";
      notiData = message.toString();
      setState(() {});
    }, onReceiveMessage: (message) async {
      log("onReceiveMessage: $message", name: "JPush");
      notiSource = "JPush onReceiveMessage";
      notiData = message.toString();
      setState(() {});
    }, onReceiveNotificationAuthorization: (message) async {
      log("onReceiveNotificationAuthorization: $message", name: "JPush");
      notiSource = "JPush onReceiveNotificationAuthorization";
      notiData = message.toString();
      setState(() {});
    }, onNotifyMessageUnShow: (message) async {
      log("onNotifyMessageUnShow: $message", name: "JPush");
      notiSource = "JPush onNotifyMessageUnShow";
      notiData = message.toString();
      setState(() {});
    }, onInAppMessageShow: (message) async {
      log("onInAppMessageShow: $message", name: "JPush");
      notiSource = "JPush onInAppMessageShow";
      notiData = message.toString();
      setState(() {});
    }, onCommandResult: (message) async {
      log("onCommandResult: $message", name: "JPush");
      notiSource = "JPush onCommandResult";
      notiData = message.toString();
      setState(() {});
    }, onInAppMessageClick: (message) async {
      log("onInAppMessageClick: $message", name: "JPush");
      notiSource = "JPush onInAppMessageClick";
      notiData = message.toString();
      setState(() {});
    }, onConnected: (message) async {
      log("onConnected: $message", name: "JPush");
      notiSource = "JPush onConnected";
      notiData = message.toString();
      setState(() {});
    });
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
              Copyable(
                title: "JPush RegistrationID",
                content: jPushID,
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
