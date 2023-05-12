import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';


class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for sending push notification
  static Future<void> sendPushNotification(
      String token,String name, String msg) async {
    try {
      final body = {
        "to": token,
        "notification": {
          "title": name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAmr0uz9s:APA91bFH7hR2UTUCnE89s63-wXAXwywDluw-DCD9Wpu2ikO-lftgiQOs3xzGnMD331pev0iiud-OsNDcLcymbmUQcgXmfEoXuMw7UNDBkM2ycha9OfDQ6jtgj3aP84f9HBVv-DgiHo7G'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
}