import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'otp.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured1 = true;
  bool _isObscured2 = true;
  bool _agreed = false;
  bool _isLoading = false; // Tracks registration progress state

  // 🆕 Added Data Collectors to hook up with Firebase
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _trySubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to the Terms & Conditions")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 📱 Converts the mobile number to a synthetic email string for Firebase Auth compatibility
      String syntheticEmail = "${_phoneController.text.trim()}@farmrent.com";

      // 💾 Push data live into Firebase Auth and Cloud Firestore 'users' collection
      await Provider.of<AuthService>(context, listen: false).signUpWithEmail(
        email: syntheticEmail,
        password: _passController.text.trim(),
        fullName: _nameController.text.trim(),
        phone: "+91 ${_phoneController.text.trim()}",
      );

      // Successfully saved! Let's advance them right to your verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OTPScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text("🚨 Registration Failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '')}"),
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Create Farmer Account", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {}, // Logic for camera picker goes here
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // 👤 Name Field Linked to Controller
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your name" : null,
              ),
              const SizedBox(height: 15),
              // 📱 Mobile Number Linked to Controller
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixText: "+91 ",
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length != 10) ? "Enter 10 digit mobile number" : null,
              ),
              const SizedBox(height: 15),
              // 🔒 Create Password Linked to Controller
              TextFormField(
                controller: _passController,
                obscureText: _isObscured1,
                decoration: InputDecoration(
                  labelText: "Create Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscured1 = !_isObscured1),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? "Password must be at least 6 characters" : null,
              ),
              const SizedBox(height: 15),
              // 🔄 Confirm Password Linked to Controller
              TextFormField(
                controller: _confirmPassController,
                obscureText: _isObscured2,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscured2 = !_isObscured2),
                  ),
                ),
                validator: (v) => v != _passController.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 15),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v!),
                title: const Text(
                  "I agree to the Terms (Fair usage & Tool safety)",
                  style: TextStyle(fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.green,
              ),
              const SizedBox(height: 20),
              // ⚡ Execution Action Layout Element
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[800],
                ),
                onPressed: _trySubmit,
                child: const Text("GET OTP", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}