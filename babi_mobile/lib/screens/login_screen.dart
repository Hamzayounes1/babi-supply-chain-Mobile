// lib/screens/login_screen.dart
//
// Stylish LoginScreen for Flutter using Provider + AuthProvider.
// Keeps all previous behavior (validation handling, onLoggedIn callback, navigation).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoggedIn;
  const LoginScreen({super.key, this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();

  bool _submitting = false;
  Map<String, String?> _fieldErrors = {};
  String? _generalError;
  bool _obscure = true;

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
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      if (res['status'] == 'validation_error') {
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
    // Responsive width limit
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 520.0 : MediaQuery.of(context).size.width * 0.94;

    return Scaffold(
      // keep AppBar minimal — stylish screen focuses on background + card
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Babi-Chain', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text('Sign in to continue', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (_generalError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _generalError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailC,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'you@example.com',
                                prefixIcon: const Icon(Icons.email),
                                errorText: _fieldErrors['email'],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  splashRadius: 18,
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                ),
                                errorText: _fieldErrors['password'],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 2,
                                ),
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Login', style: TextStyle(fontSize: 16)),
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
                                  onPressed: () => Navigator.of(context).pushNamed('/forgot'),
                                  child: const Text('Forgot?'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // small footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Powered by', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 6),
                            Text('Hamza-Younes', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
