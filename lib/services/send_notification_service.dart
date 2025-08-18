import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:sewamitra/services/get_service_key.dart';

class SendNotificationService {
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
}) async {
    String serverKey = await GetServerKey().getServerKeyToken();
    print("server key: $serverKey");
    String url =
        "https://fcm.googleapis.com/v1/projects/sewamitra-4cbd7/messages:send";
    var headers = <String, String>{
      "Content-Type": 'application/json',
      "Authorization": 'Bearer $serverKey',
    };
    // message
    Map<String, dynamic> message = {
      "message": {
        "token":token,
        "notification": {
          "body": body,
          "title":title,},
          "data":data,
      },
    };
  //   hitting api
    final http.Response response = await  http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print("notification send successfully!");

    }else{
      print("notification send failed!");
    }
  }




  static Future<void> sendBookingResponse(
      String userId, String appointmentId, String status) async {
    final notificationRef = _dbRef
        .child('notifications')
        .child(userId)
        .push();

    await notificationRef.set({
      'id': notificationRef.key,
      'type': 'booking_response',
      'title': status == 'accepted'
          ? 'Booking Accepted'
          : 'Booking Rejected',
      'body': status == 'accepted'
          ? 'Your booking has been accepted!'
          : 'Your booking has been rejected.',
      'appointmentId': appointmentId,
      'status': status,
      'read': false,
      'timestamp': ServerValue.timestamp,
    });
  }
}
