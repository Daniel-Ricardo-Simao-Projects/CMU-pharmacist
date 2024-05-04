import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/user_service.dart';

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
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
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
              onPressed: _saveUsername,
              child: const Text('Create User'),
            ),
          ],
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
