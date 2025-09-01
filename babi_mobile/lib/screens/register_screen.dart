import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegistered;
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

  final Color accentColor = Colors.indigo.shade600;

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (_generalError != null) ...[
                      Text(_generalError!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    _buildTextField(_nameC, 'Full name', hint: 'John Doe', error: _fieldErrors['name']),
                    const SizedBox(height: 12),
                    _buildTextField(_emailC, 'Email', hint: 'you@example.com', error: _fieldErrors['email'], keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _buildTextField(_passC, 'Password', error: _fieldErrors['password'], obscure: true),
                    const SizedBox(height: 12),
                    _buildTextField(_pass2C, 'Confirm password', error: _fieldErrors['password_confirmation'], obscure: true),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Create account', style: TextStyle(fontSize: 16)),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {String? hint, String? error, bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        if (label == 'Email') {
          final regex = RegExp(r'.+@.+\..+');
          if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
        }
        if (label == 'Password' && v.length < 6) return 'Password must be at least 6 characters';
        if (label == 'Confirm password' && v != _passC.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}
