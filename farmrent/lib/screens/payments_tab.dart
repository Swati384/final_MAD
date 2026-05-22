import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

class PaymentsTab extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const PaymentsTab({super.key, required this.bookings});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  String activeTimeFilter = "ALL"; // ALL, MONTH, WEEK

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime(2026, 5, 21);

    // Dynamic reactive filtering pipeline parsing logic
    List<Map<String, dynamic>> filteredTransactions = widget.bookings.where((b) {
      if (b['status'] == 'PENDING') return false;
      if (activeTimeFilter == "WEEK") {
        return now.difference(b['timestamp']).inDays <= 7;
      } else if (activeTimeFilter == "MONTH") {
        return now.difference(b['timestamp']).inDays <= 30;
      }
      return true; // ALL
    }).toList();

    double totalGained = filteredTransactions
        .where((t) => t['role'] == 'lending')
        .fold(0.0, (sum, item) => sum + item['cost']);

    double totalSpent = filteredTransactions
        .where((t) => t['role'] == 'renting')
        .fold(0.0, (sum, item) => sum + item['cost']);

    return Column(
      children: [
        buildGlobalSearchHeader(title: "Dual-Accounting Ledger Matrix"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Incident Liability Alert Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                child: Row(
                  children: const [
                    Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text("Damage Claim Registered: ₹1,200 reported by Provider Suresh for cleaning overhead parameters.", style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Horizontal Date-Range Filter Shortcut Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter Matrix View", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      _buildFilterChip("All Time", "ALL"),
                      _buildFilterChip("This Month", "MONTH"),
                      _buildFilterChip("7 Days", "WEEK"),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Side-by-Side Balance Aggregation Summaries
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Gained Lending", style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("+₹${totalGained.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Spent Renting", style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("−₹${totalSpent.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              const Text("Transaction Ledger History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),

              ...filteredTransactions.map((tx) {
                bool isGain = tx['role'] == 'lending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5EBE5))),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isGain ? const Color(0xFFE8F5E9) : Colors.grey[100],
                        child: Icon(Icons.account_balance_wallet, color: isGain ? const Color(0xFF4CAF50) : Colors.grey, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Cleared via ${tx['paymentMethod']} • Ref #TXN${tx['id']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        "${isGain ? '+' : '−'}₹${tx['cost']}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isGain ? const Color(0xFF4CAF50) : Colors.black87),
                      )
                    ],
                  ),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFilterChip(String title, String key) {
    bool isSelected = activeTimeFilter == key;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: ChoiceChip(
        label: Text(title, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        selectedColor: Colors.green[700],
        backgroundColor: Colors.grey[200],
        onSelected: (val) => setState(() => activeTimeFilter = key),
      ),
    );
  }
}