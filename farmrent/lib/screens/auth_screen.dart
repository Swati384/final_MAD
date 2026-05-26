import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart'; // 👈 Imported directly from the same folder now!

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoginMode = true;
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      if (isLoginMode) {
        await authService.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚨 Authentication Failed: ${error.toString()}"),
          backgroundColor: Colors.red[800],
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLoginMode ? "Welcome to FarmRent" : "Create Account",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                    const SizedBox(height: 20),
                    if (!isLoginMode) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Full Name", icon: Icon(Icons.person, color: Colors.green)),
                        validator: (val) => val!.isEmpty ? "Please enter your name" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "Phone Number", icon: Icon(Icons.phone, color: Colors.green)),
                        validator: (val) => val!.isEmpty ? "Please enter a phone number" : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Email Address", icon: Icon(Icons.email, color: Colors.green)),
                      validator: (val) => !val!.contains('@') ? "Please enter a valid email" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password", icon: Icon(Icons.lock, color: Colors.green)),
                      validator: (val) => val!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        isLoginMode ? "LOGIN" : "REGISTER",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => isLoginMode = !isLoginMode),
                      child: Text(
                        isLoginMode ? "Don't have an account? Sign Up" : "Already registered? Login",
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}