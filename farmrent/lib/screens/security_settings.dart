import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Settings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Account Security Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _securityTile(Icons.lock_outline, "Change Password", "Update your account password"),
          _securityTile(Icons.phonelink_lock, "Two-Factor Authentication", "Enabled via linked mobile"),
          _securityTile(Icons.history, "Login Activity", "Check recent sessions"),
          const Divider(height: 40),
          _securityTile(Icons.delete_forever_outlined, "Deactivate Account", "Permanently remove your data", isDanger: true),
        ],
      ),
    );
  }

  Widget _securityTile(IconData icon, String title, String subtitle, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.green[700]),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.red : Colors.black87, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {},
    );
  }
}
