import 'package:flutter/material.dart';
import 'package:flutter_frontend/main.dart';
import 'package:flutter_frontend/pages/create_user_page.dart';
import 'package:flutter_frontend/themes/colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../database/app_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userService = UserService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  BuildContext? _dialogContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Login',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 700)],
            color: accentColor,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
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
                      const Icon(Icons.spa, size: 150, color: primaryColor),
                      const Text(
                        'PharmacIST',
                        style: TextStyle(
                          fontFamily: 'JosefinSans',
                          fontVariations: [FontVariation('wght', 700)],
                          color: primaryColor,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 60),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          fontFamily: 'JosefinSans',
                          fontVariations: [FontVariation('wght', 400)],
                          color: text1Color,
                          fontSize: 15,
                        ),
                        cursorColor: primaryColor,
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontVariations: [FontVariation('wght', 400)],
                            color: text1Color,
                            fontSize: 15,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 10),
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
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
                          color: text1Color,
                          fontSize: 15,
                        ),
                        cursorColor: primaryColor,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontVariations: [FontVariation('wght', 400)],
                            color: text1Color,
                            fontSize: 15,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 10),
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _login,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontVariations: [FontVariation('wght', 600)],
                            color: text2Color,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateUserPage()),
                        ),
                        child: const Text(
                          'Create Username',
                          style: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontVariations: [FontVariation('wght', 400)],
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

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    _dialogContext = context; // Store buildcontext temporarily

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    bool isAuthenticated =
        await _userService.authenticateUser(username, password);

    // Check if BuildContext is valid
    if (_dialogContext != null && mounted) {
      if (isAuthenticated) {
        final database =
            await $FloorAppDatabase.databaseBuilder('app_database.db').build();
        final userDao = database.userDao;

        // Clear previous logged in status
        User? loggedInUser = await userDao.findLoggedInUser();
        if (loggedInUser != null) {
          await userDao.updateUser(User(
            id: loggedInUser.id,
            name: loggedInUser.name,
            password: loggedInUser.password,
            isLogged: false,
          ));
        }

        // Insert or update the current user
        User? user = await userDao.findUserById(1);
        if (user != null) {
          await userDao.updateUser(User(
            id: 1,
            name: username,
            password: password,
            isLogged: true,
          ));
        } else {
          await userDao.insertUser(User(
            id: 1,
            name: username,
            password: password,
            isLogged: true,
          ));
        }

        Navigator.pushReplacement(
          _dialogContext!,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        print(
            "Failed to login with username: $username and password: $password");
        ScaffoldMessenger.of(_dialogContext!).showSnackBar(
          const SnackBar(
            content: Text('Failed to login'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
