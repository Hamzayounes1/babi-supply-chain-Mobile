// lib/screens/register_screen.dart
//
// RegisterScreen for Flutter 4 using Provider + AuthProvider (lib/providers/auth_provider.dart)
// - Validates name, email, password, password confirmation
// - Submits to AuthProvider.register(...) which should return a Map with a 'status' key
// - Handles Laravel-style 422 validation errors (errors: { field: [msgs] }) and displays first error per field
// - On success navigates to '/home' or calls optional onRegistered callback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegistered; // optional callback to run after successful registration
  const RegisterScreen({super.key, this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  final TextEditingController _pass2C = TextEditingController();

  bool _submitting = false;
  Map<String, String?> _fieldErrors = {};
  String? _generalError;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _pass2C.dispose();
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
      final res = await auth.register(
        _nameC.text.trim(),
        _emailC.text.trim(),
        _passC.text,
        _pass2C.text,
      );

      setState(() => _submitting = false);

      if (res['status'] == 'ok') {
        _showSnack('Account created');
        if (widget.onRegistered != null) {
          widget.onRegistered!();
        } else {
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
        _generalError = res['message']?.toString() ?? 'Registration failed';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (_generalError != null) ...[
                      Text(_generalError!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _nameC,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        hintText: 'John Doe',
                        errorText: _fieldErrors['name'],
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
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
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass2C,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        errorText: _fieldErrors['password_confirmation'],
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your password';
                        if (v != _passC.text) return 'Passwords do not match';
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
                            : const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Have an account? Login'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
