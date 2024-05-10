import 'package:flutter/material.dart';
import 'package:flutter_frontend/main.dart';
import 'package:flutter_frontend/pages/create_user_page.dart';
import '../services/user_service.dart';

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
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateUserPage()),
                    ),
                    child: const Text('Create Username'),
                  ),
                ],
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
        Navigator.pushReplacement(
          _dialogContext!,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
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
