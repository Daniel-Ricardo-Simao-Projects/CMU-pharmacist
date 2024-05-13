import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/user_service.dart';
import 'package:flutter_frontend/themes/colors.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  BuildContext? _dialogContext;
  final _userService = UserService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: text2Color),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: text2Color,
        ),
        backgroundColor: primaryColor,
        title: const Text(
          'Create Username',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 700)],
            color: text2Color,
            fontSize: 20,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 45, right: 45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.spa, size: 150, color: backgroundColor),
                const Text(
                  'PharmacIST',
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 700)],
                    color: backgroundColor,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    color: text2Color,
                    fontSize: 15,
                  ),
                  cursorColor: backgroundColor,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      color: text2Color,
                      fontSize: 15,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 10),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    color: text2Color,
                    fontSize: 15,
                  ),
                  cursorColor: backgroundColor,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      color: text2Color,
                      fontSize: 15,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 10),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: backgroundColor),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _saveUsername,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(backgroundColor),
                  ),
                  child: const Text(
                    'Create User',
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 600)],
                      color: accentColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveUsername() async {
    _dialogContext = context; // Store buildcontext temporarily

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    bool isValidUsername = await _userService.addUser(username, password);

    // Check if BuildContext is valid
    if (_dialogContext != null && mounted) {
      if (isValidUsername) {
        Navigator.of(_dialogContext!).pop();
      } else {
        ScaffoldMessenger.of(_dialogContext!).showSnackBar(
          const SnackBar(
            content: Text('Failed to add user'),
          ),
        );
      }
    }
  }
}
