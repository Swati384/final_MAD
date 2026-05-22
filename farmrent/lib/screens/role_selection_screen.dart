import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart'; // Pointing to your new unified shell navigation file

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 64, color: Color(0xFF4CAF50)),
            const SizedBox(height: 16),
            const Text(
                "Welcome to FarmRent",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blackDE)
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Access your customized dual-role hub to manage listings or book machinery instantly.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(260, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              onPressed: () {
                // Remove all previous screens and boot directly into the Central Dashboard Hub
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CentralDashboardHub()),
                      (route) => false,
                );
              },
              child: const Text(
                  "ENTER CENTRAL HUB",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}