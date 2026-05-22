import 'package:flutter/material.dart';
import 'perm.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Verify Your Mobile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Enter the 4 digit code sent via SMS", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // --- UPDATED ROW START ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                    (i) => SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number, // Shows number pad
                    maxLength: 1, // Only 1 digit per box
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      counterText: "", // Hides the "0/1" text under boxes
                    ),
                    onChanged: (value) {
                      // If user types a number, move focus to NEXT box
                      if (value.length == 1 && i < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                      // If user deletes, move focus to PREVIOUS box
                      if (value.isEmpty && i > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            // --- UPDATED ROW END ---

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[700]
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PermScreen())
              ),
              child: const Text("VERIFY & CONTINUE", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}