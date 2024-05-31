import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/pages/add_pharmacy_page.dart';
import 'package:flutter_frontend/pages/find_medicine_page.dart';
import 'package:flutter_frontend/pages/maps_page.dart';
import 'package:flutter_frontend/pages/user_login_page.dart';
import 'package:flutter_frontend/pages/user_profile_page.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'models/user_model.dart';
import 'services/user_service.dart';

String? notifTitle, notifBody;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    systemNavigationBarColor: backgroundColor, // Transparent navigation bar
  ));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  log(const String.fromEnvironment('URL'));

  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  final userDao = database.userDao;
  User? loggedInUser = await userDao.findLoggedInUser();
  database.close();

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(loggedInUser: loggedInUser)));
}

class MyApp extends StatelessWidget {
  final User? loggedInUser;

  const MyApp({super.key, this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
    ));

    return FutureBuilder<String?>(
      future: FirebaseMessaging.instance.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final fcmToken = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PharmacIST',
          theme: Provider.of<ThemeProvider>(context).getTheme,
          home: loggedInUser == null
              ? LoginPage(fcmToken: fcmToken)
              : HomePage(fcmToken: fcmToken),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String? fcmToken;

  const HomePage({super.key, required this.fcmToken});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  final _pageOptions = <Widget>[
    const MapsPage(),
    const AddPharmacyPage(),
    const FindMedicinePage(),
  ];

  @override
  void initState() {
    super.initState();

    UserService userService = UserService();
    userService.updateFcmToken(widget.fcmToken);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Got a message whilst in the foreground!");
      log("Message data: ${message.data}");
      if (message.notification != null) {
        log("Message also contained a notification: ${message.notification}");
        setState(() {
          notifTitle = message.notification!.title;
          notifBody = message.notification!.body;
        });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Opened a notification");
      log("Message data: ${message.data}");
      if (message.notification != null) {
        log("Message also contained a notification: ${message.notification}");
        _showNotification(message.notification!);
      }
    });
  }

  Future<void> _showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    log("Notification title: ${notification.title}");

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pageOptions,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index == 3) {
            showModalBottomSheet(
                context: context, builder: (context) => const UserProfilePage());
          } else {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
        backgroundColor: Theme.of(context).colorScheme.background,
        indicatorColor: Theme.of(context).colorScheme.primary,
        selectedIndex: _currentPageIndex,
        height: 50,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.map_outlined, color: text2Color),
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle_outline, color: text2Color),
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Pharmacy',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search_outlined, color: text2Color),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.account_circle_outlined, color: text2Color),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
        //currentIndex: _selectedIndex,
        //onTap: _onItemTapped,
      ),
    );
  }
}

