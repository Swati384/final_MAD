import 'package:flutter/material.dart';

class LandPlotManagementScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;

  const LandPlotManagementScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Land Plot Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Simulated Map View
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.blue[50],
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.location_on, color: Colors.red[700], size: 48),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Your Registered Farm Plots", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _plotCard("Main Paddy Field", "1.2 Acres", "KA-01-45"),
                _plotCard("Orchard Section", "0.8 Acres", "KA-01-46"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text("Mark New Plot Perimeter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plotCard(String title, String size, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.landscape, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Size: $size • ID: $id"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
