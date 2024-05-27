import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/user_login_page.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:flutter_frontend/themes/themes.dart';
import 'package:provider/provider.dart';

import '../pages/user_login_page.dart';

import '../services/user_service.dart';

enum ThemeType { light, dark, system }

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _userInfo(context),
          const SizedBox(height: 20),
          _setThemeButton(context),
          const SizedBox(height: 20),
          _logoutButton(context),
        ],
      ),
    );
  }

  Padding _setThemeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.dark_mode_outlined,
                  size: 30,
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .secondary),
              const SizedBox(width: 20),
              Text(
                'Set Theme',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .secondary,
                  fontFamily: 'JosefinSans',
                  fontVariations: const [FontVariation('wght', 400)],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          PopupMenuButton<ThemeType>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: Icon(Icons.tune,
                color: Provider.of<ThemeProvider>(context)
                    .getTheme
                    .colorScheme
                    .secondary,
                size: 30),
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .primary,
            onSelected: (ThemeType result) {
              switch (result) {
                case ThemeType.light:
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setTheme(lightTheme);
                  break;
                case ThemeType.dark:
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setTheme(darkTheme);
                  break;
                case ThemeType.system:
                  final brightness = MediaQuery.of(context).platformBrightness;
                  Provider.of<ThemeProvider>(context, listen: false)
                      .setSystemTheme(brightness);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeType>>[
              const PopupMenuItem<ThemeType>(
                value: ThemeType.light,
                child: Text(
                  'Light',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
                  ),
                ),
              ),
              const PopupMenuItem<ThemeType>(
                value: ThemeType.dark,
                child: Text(
                  'Dark',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
                  ),
                ),
              ),
              const PopupMenuItem<ThemeType>(
                value: ThemeType.system,
                child: Text(
                  'System',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Icon(Icons.logout,
              size: 30,
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary),
          const SizedBox(width: 10),
          TextButton(
              onPressed: () {
                UserService().logout();
                // pop everything and go to login page
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage(fcmToken: '')));
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .secondary,
                  fontFamily: 'JosefinSans',
                  fontVariations: const [FontVariation('wght', 400)],
                  fontSize: 16,
                ),
              )),
        ],
      ),
    );
  }

  Padding _userInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.account_circle,
              size: 50,
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary),
          const SizedBox(width: 10),
          const Text(
            'Alice Bob DRS',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontVariations: [FontVariation('wght', 400)],
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
