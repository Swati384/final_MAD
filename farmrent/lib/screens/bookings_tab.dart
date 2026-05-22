import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

class BookingsTab extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onBookingsChanged;

  const BookingsTab({super.key, required this.bookings, required this.onBookingsChanged});

  @override
  Widget build(BuildContext context) {
    // Pipeline split sorting architectures
    final lendingItems = bookings.where((b) => b['role'] == 'lending' || b['status'] == 'PENDING').toList();
    final rentingItems = bookings.where((b) => b['role'] == 'renting' && b['status'] != 'PENDING').toList();

    return Column(
      children: [
        buildGlobalSearchHeader(title: "Deployment Pipeline Ledger"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ACTIONABLE REQUEST INBOX PANEL
              Row(
                children: const [
                  Icon(Icons.inbox, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text("📥 SECTION A: GIVING (Lending Out My Fleet)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 10),

              lendingItems.isEmpty
                  ? const Padding(padding: EdgeInsets.all(12.0), child: Text("No incoming deployment listings currently active.", style: TextStyle(color: Colors.grey, fontSize: 12)))
                  : Column(
                children: lendingItems.map((item) {
                  bool isPending = item['status'] == 'PENDING';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: isPending ? Colors.amber[50] : const Color(0xFFF1F4F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isPending ? Colors.amber.shade300 : Colors.grey.shade300)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: isPending ? Colors.amber : Colors.green, borderRadius: BorderRadius.circular(8)),
                              child: Text(item['status'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item['meta'], style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        Text("Revenue Matrix: ₹${item['cost']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        if (isPending) ...[
                          const Divider(height: 20),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                                onPressed: () {
                                  item['status'] = 'ACTIVE';
                                  item['role'] = 'lending'; // Move inside Lender Giving tree
                                  onBookingsChanged();
                                },
                                child: const Text("Accept Request", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  bookings.remove(item);
                                  onBookingsChanged();
                                },
                                child: const Text("Decline", style: TextStyle(color: Colors.red, fontSize: 12)),
                              )
                            ],
                          )
                        ] else if (item['status'] == 'ACTIVE') ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("🗺️ ${item['route']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
                          )
                        ]
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.outbound, color: Colors.blue, size: 18),
                  SizedBox(width: 6),
                  Text("📤 SECTION B: TAKING (Hiring for My Farm)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 10),

              Column(
                children: rentingItems.map((item) {
                  bool isActive = item['status'] == 'ACTIVE';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(isActive ? "ACTIVE ✅" : "COMPLETED ⏳", style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item['meta'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("Duration: ${item['dates'] ?? 'Closed session'}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        Text("Cost Outflow: ₹${item['cost']} via ${item['paymentMethod']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        if (isActive) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("🗺️ ${item['route']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], elevation: 0),
                                  onPressed: () {},
                                  child: const Text("Report Issue", style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0),
                                  onPressed: () {},
                                  child: const Text("Call Fleet Operator", style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              )
                            ],
                          )
                        ] else ...[
                          const SizedBox(height: 6),
                          item['rated'] == true
                              ? Row(children: const [Icon(Icons.star, color: Colors.orange, size: 14), Text(" Rated 5.0", style: TextStyle(fontSize: 12, color: Colors.grey))])
                              : TextButton(
                            onPressed: () { item['rated'] = true; onBookingsChanged(); },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text("Rate Now ⭐", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ],
    );
  }
}