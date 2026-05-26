import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart'; // ✅ Relative import works perfectly because it's in the same folder!
import 'sign_up.dart';      // ✅ Relative import points perfectly to your custom SignUp file!

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 📱 Formats the phone number input to match your Firebase Account backend structure
      String configuredEmail = "${_usernameController.text.trim()}@farmrent.com";

      // 🔒 Firebase Authentication Security Engine Execution
      await Provider.of<AuthService>(context, listen: false).loginWithEmail(
        email: configuredEmail,
        password: _passwordController.text.trim(),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text("❌ Access Denied: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '')}"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // 🚜 Custom App Branding
                  Icon(Icons.agriculture, size: 110, color: Colors.green[600]),
                  const SizedBox(height: 8),
                  Text(
                    "FarmRent",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Formal Tool Sharing & Farmer Network",
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // 👤 User ID Input field wrapper
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "User ID or Mobile Number",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.trim().isEmpty ? "Please enter your User ID or Mobile Number" : null,
                  ),
                  const SizedBox(height: 20),

                  // 🔒 Password Input field wrapper
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.isEmpty ? "Please enter your password" : null,
                  ),
                  const SizedBox(height: 35),

                  // ⚡ Rounded SIGN IN Button
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      "SIGN IN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔁 Bottom Action navigation link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New user? ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      GestureDetector(
                        onTap: () { // ✅ Changed from 'onPressed' to 'onTap' (GestureDetectors use onTap!)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUp()), // ✅ Changed from SignUpScreen to your real class Name: SignUp
                          );
                        },
                        child: Text(
                          "Register Here",
                          style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}