// lib/screens/login_screen.dart
//
// LoginScreen for Flutter 4 using Provider + the AuthProvider from auth_provider.dart
// - Validates email & password
// - Submits to AuthProvider.login(...) which should return a Map with a 'status' key
// - Handles Laravel-style 422 validation errors (errors: { field: [msgs] })
// - On success navigates to '/home' or calls optional onLoggedIn callback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoggedIn; // optional callback to run after successful login
  const LoginScreen({super.key, this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();

  bool _submitting = false;
  Map<String, String?> _fieldErrors = {};
  String? _generalError;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _showSnack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit() async {
    setState(() {
      _fieldErrors = {};
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final res = await auth.login(_emailC.text.trim(), _passC.text);
      setState(() => _submitting = false);

      if (res['status'] == 'ok') {
        _showSnack('Logged in');
        if (widget.onLoggedIn != null) {
          widget.onLoggedIn!();
        } else {
          // replace current route with home
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      if (res['status'] == 'validation_error') {
        // Map Laravel-style errors: { field: [ "msg1", "msg2" ] }
        final errors = <String, String?>{};
        final raw = res['errors'] as Map? ?? {};
        raw.forEach((k, v) {
          if (v is List && v.isNotEmpty) {
            errors[k.toString()] = v.first.toString();
          } else {
            errors[k.toString()] = v?.toString();
          }
        });
        setState(() {
          _fieldErrors = errors;
        });
        return;
      }

      // general error fallback
      setState(() {
        _generalError = res['message']?.toString() ?? 'Login failed';
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _generalError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If you want to auto-redirect when already logged in, you can check AuthProvider here:
    // final auth = Provider.of<AuthProvider>(context);
    // if (!auth.loading && auth.token != null) WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, '/home'));

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_generalError != null) ...[
                        Text(_generalError!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          errorText: _fieldErrors['email'],
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          final regex = RegExp(r'.+@.+\..+');
                          if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passC,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _fieldErrors['password'],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/register'),
                            child: const Text('Create an account'),
                          ),
                          TextButton(
                            onPressed: () {
                              // implement forgot password navigation if you have the route
                              Navigator.of(context).pushNamed('/forgot');
                            },
                            child: const Text('Forgot?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
