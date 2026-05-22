import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

class ProfileTab extends StatelessWidget {
final int fleetCount;
const ProfileTab({super.key, required this.fleetCount});

@override
Widget build(BuildContext context) {
return Column(
children: [
buildGlobalSearchHeader(title: "Partner Portfolio Management"),
Expanded(
child: ListView(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
children: [
// Camera-Badged Avatar Image Matrix Frame Stack
Center(
child: Stack(
children: [
Container(
padding: const EdgeInsets.all(3),
decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF81C784), width: 2)),
child: CircleAvatar(
radius: 50, backgroundColor: const Color(0xFFC8E6C9),
child: Icon(Icons.person, size: 54, color: Colors.green[800]),
),
),
Positioned(
bottom: 2, right: 2,
child: Container(
padding: const EdgeInsets.all(6),
decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
child: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50), size: 14),
),
)
],
),
),
const SizedBox(height: 12),

// Accounts Metrics Scoreboard Layout
Center(
child: Column(
children: [
const Text("Vinutha Shivalingaiah", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const Text("Verified Unified Agri-Partner Matrix", style: TextStyle(color: Colors.grey, fontSize: 12)),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_buildReputationMetricBadge("Borrower Metrics", "4.9 ⭐"),
const SizedBox(width: 10),
_buildReputationMetricBadge("Lender Fleet", "4.7 ⭐"),
],
)
],
),
),
const Divider(height: 30, color: Color(0xFFEEEEEE)),

// Merged Configuration Management Settings Options
_profileMenuTile(Icons.phone_android, "Authentication Channel", "98765 43210"),
_profileMenuTile(Icons.location_on_outlined, "Geospatial Land Plots", "Bengaluru South Coordination Hub"),
_profileMenuTile(Icons.agriculture, "Active Registered Garage Fleet", "$fleetCount items currently managed"),
_profileMenuTile(Icons.help_outline, "Platform Help Desk & Guidelines Documentation", "Access legal FAQ parameters"),

const SizedBox(height: 32),
OutlinedButton(
style: OutlinedButton.styleFrom(
side: const BorderSide(color: Color(0xFFEF5350)),
minimumSize: const Size(double.infinity, 48),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
),
onPressed: () {},
child: const Text("Terminate Secure Session (Log Out)", style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 13)),
)
],
),
)
],
);
}

Widget _buildReputationMetricBadge(String title, String score) {
return Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
child: Column(
children: [
Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
Text(score, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
],
),
);
}

Widget _profileMenuTile(IconData leadIcon, String headline, String contextLine) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 10),
child: Row(
children: [
Icon(leadIcon, color: const Color(0xFF4CAF50), size: 22),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(headline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
if (contextLine.isNotEmpty) Text(contextLine, style: const TextStyle(fontSize: 11, color: Colors.grey)),
],
),
),
const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
],
),
);
}
}