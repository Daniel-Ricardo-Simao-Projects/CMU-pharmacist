import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/database/app_database.dart';

class ShowNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
        if (payload != null) {
          final pharmacyID = int.tryParse(payload);
          if (pharmacyID == null) {
            return;
          }
          final database = await $FloorAppDatabase
              .databaseBuilder('app_database.db')
              .build();
          final pharmacy =
              await database.pharmacyDao.findPharmacyById(pharmacyID);
          if (pharmacy == null) {
            return;
          }

          print('Notification tapped: ${pharmacy.name}\n\n\n');

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PharmacyInfoPanel(pharmacy: pharmacy),
            ),
          );
        }
      },
    );
  }

  Future<void> showNotification(
      String body, String message, int pharmacyID) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_channel',
      'Very important notification!!',
      description: 'the first notification',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      body,
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
        ),
      ),
      payload: pharmacyID.toString(),
    );
  }
}
