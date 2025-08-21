import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:sewamitra/main.dart';

// for notification requests
class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      Get.snackbar(
        'Notification permission denied',
        "please allow notification to receive updates.",
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  // get token

  Future<String> getDeviceToken() async {
    NotificationSettings Settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    String? token = await messaging.getToken();
    print("token id $token");
    return token!;
  }

  //init
  void initLocalNotification(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iOSInitSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (payload) {
        handleMessege(context, message);
      },
    );
  }

  //   firebase init

  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (kDebugMode) {
        print("message title ${notification!.title}");
        print("message body ${notification!.body}");
      }
      // ios
      if (Platform.isIOS) {
        iosForegroundNotification();
      }

      //   android
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        // handleMessege(context, message);
        showNotification(message);
      }
    });
  }

  // function to show notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: "channel Disc",
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: channel.sound,
        );
    //   ios setting
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    // merge notification
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
  //   show notification
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
        payload: message.data.toString(),
      );
    });
  }

  // background and terminated
  Future<void> setupInteractedMessage(BuildContext context) async {
    //   background state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessege(context, message);
    });
    // terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null && message.data.isNotEmpty) {
        handleMessege(context, message);
      }
    });
  }

  // handler
  Future<void> handleMessege(
    BuildContext context,
    RemoteMessage message,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // ios message
  Future iosForegroundNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
