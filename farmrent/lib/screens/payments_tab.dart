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

    // Filter pipeline logic: Exclude both Pending and Denied items from accounting data pools
    List<Map<String, dynamic>> filteredTransactions = widget.bookings.where((b) {
      final String status = (b['status'] ?? '').toString().toUpperCase();
      if (status == 'PENDING' || status == 'DENIED') return false;
      
      final timestamp = b['timestamp'];
      // Handle different timestamp types (DateTime or Timestamp)
      DateTime? dt;
      if (timestamp is DateTime) {
        dt = timestamp;
      } else if (timestamp != null && timestamp.runtimeType.toString() == 'Timestamp') {
        // Handle cloud_firestore Timestamp without importing it if possible, 
        // or just use a generic conversion if available.
        try {
          dt = (timestamp as dynamic).toDate();
        } catch (e) {
          dt = null;
        }
      }

      if (dt == null) return activeTimeFilter == "ALL";

      if (activeTimeFilter == "WEEK") {
        return now.difference(dt).inDays <= 7;
      } else if (activeTimeFilter == "MONTH") {
        return now.difference(dt).inDays <= 30;
      }
      return true; // ALL
    }).toList();

    double totalGained = 0.0;
    try {
      totalGained = filteredTransactions
          .where((t) => (t['role'] ?? '').toString().toLowerCase() == 'lending')
          .fold(0.0, (sum, item) => sum + (double.tryParse((item['cost'] ?? 0).toString()) ?? 0.0));
    } catch (e) {
      debugPrint("Error calculating totalGained: $e");
    }

    double totalSpent = 0.0;
    try {
      totalSpent = filteredTransactions
          .where((t) => (t['role'] ?? '').toString().toLowerCase() == 'renting')
          .fold(0.0, (sum, item) => sum + (double.tryParse((item['cost'] ?? 0).toString()) ?? 0.0));
    } catch (e) {
      debugPrint("Error calculating totalSpent: $e");
    }

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
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: const Color(0xFFFFCDD2))
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                      child: const Icon(Icons.priority_high, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Damage Claim Registered: ₹1,200 reported by Provider Suresh for cleaning overhead parameters.", 
                        style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.bold)
                      )
                    ),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), 
                        borderRadius: BorderRadius.circular(14), 
                        border: Border.all(color: Colors.green.shade100, width: 2)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Gained Lending", style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text("+₹${totalGained.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(14), 
                        border: Border.all(color: Colors.grey.shade200, width: 2)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Spent Renting", style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text("−₹${totalSpent.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black87)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              const Text("Transaction Ledger History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),

              filteredTransactions.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_edu, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text("No transactions recorded for this period.", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              )
                  : Column(
                children: filteredTransactions.map((tx) {
                  bool isGain = tx['role'] == 'lending';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: Colors.grey.shade100)
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isGain ? const Color(0xFFE8F5E9) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Icon(
                            isGain ? Icons.account_balance_wallet : Icons.shopping_bag_outlined, 
                            color: isGain ? const Color(0xFF4CAF50) : Colors.grey, 
                            size: 24
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['title'] ?? 'Unknown Transaction', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                "Cleared via ${tx['paymentMethod'] ?? 'Unknown'} • Ref #TXN${(tx['id'] ?? '000000').toString().padRight(6, '0').substring(0, 6)}",
                                style: const TextStyle(color: Colors.grey, fontSize: 11)
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${isGain ? '+' : '−'}₹${tx['cost']}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isGain ? const Color(0xFF2E7D32) : Colors.black87),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
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