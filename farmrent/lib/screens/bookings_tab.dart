import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_service.dart';
import 'booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsTab extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onBookingsChanged;

  const BookingsTab({
    super.key,
    required this.bookings,
    required this.onBookingsChanged,
  });

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  final BookingService _bookingService = BookingService();
  bool isLenderView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _reportIssue(Map<String, dynamic> item) {
    final TextEditingController issueController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Report Issue: ${item['title']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Describe the problem:", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe the issue with the machinery...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[100],
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (issueController.text.isNotEmpty) {
                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);
                      await _reportService.submitReport(
                        bookingId: item['id'],
                        title: item['title'],
                        description: issueController.text,
                        role: isLenderView ? 'lender' : 'renter',
                      );
                      nav.pop();
                      sm.showSnackBar(const SnackBar(content: Text("Issue reported successfully.")));
                    }
                  },
                  child: const Text("Submit Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsSection(String bookingId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _reportService.getReportsForBooking(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reported Issues:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red[700])),
              ...snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Text("• ${data['description']}", style: const TextStyle(fontSize: 11, color: Colors.black87));
              }),
            ],
          ),
        );
      },
    );
  }

  // --- RENTER CARD BUILDERS ---

  Widget _buildRenterPendingCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow("Legal Number", item['legalNumber']),
            _buildInfoRow("Vehicle Age", item['vehicleAge']),
            _buildInfoRow("Last Service", item['lastServiceDate']),
            _buildInfoRow("Last Rented", item['lastRentedDate']),
            _buildInfoRow("Lender", item['lenderName']),
            const SizedBox(height: 12),
            const Text("Payment Options:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentIcon(item, Icons.payments, "Cash"),
                _buildPaymentIcon(item, Icons.credit_card, "Card"),
                _buildPaymentIcon(item, Icons.account_balance, "UPI"),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _reportIssue(item),
              icon: const Icon(Icons.report_problem, size: 18),
              label: const Text("Report Issue"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRenterInUseCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            _buildInfoRow("Legal Number", item['legalNumber']),
            _buildInfoRow("Vehicle Age", item['vehicleAge']),
            _buildInfoRow("Rented On", item['dates']),
            _buildInfoRow("Days Used", "${item['durationDays']} Days"),
            _buildInfoRow("Lender", item['lenderName']),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reportIssue(item),
                    icon: const Icon(Icons.report_problem, size: 18),
                    label: const Text("Report Issue"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(item['lenderPhone'] ?? '9112345678'),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call Fleet"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            _buildReportsSection(item['id']),
          ],
        ),
      ),
    );
  }

  Widget _buildRenterCompletedCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Divider(),
            _buildInfoRow("Legal Number", item['legalNumber']),
            _buildInfoRow("Vehicle Age", item['vehicleAge']),
            _buildInfoRow("Rent Duration", item['dates']),
            _buildInfoRow("Days Used", "${item['durationDays']} Days"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Paid:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("₹${item['cost']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LENDER CARD BUILDERS ---

  Widget _buildLenderRequestedCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Request for: ${item['title']}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow("User", item['renterName']),
            _buildInfoRow("Address", item['userAddress']),
            _buildInfoRow("Timeframe", item['dates']),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (item['id'] != null) {
                        await _bookingService.updateBooking(item['id'], {
                          'status': 'ACTIVE',
                          'role': 'lending',
                        });
                        widget.onBookingsChanged();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("🎉 Request Accepted! Moving item into active lending cycle.")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                    child: const Text("Accept"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (item['id'] != null) {
                        await _bookingService.updateBooking(item['id'], {'status': 'DENIED'});
                        widget.onBookingsChanged();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("❌ Request Declined.")),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                    child: const Text("Decline"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLenderRentedCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("In Use: ${item['title']}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            _buildInfoRow("User", item['renterName']),
            _buildInfoRow("Legal #", item['legalNumber']),
            _buildInfoRow("Duration", item['dates']),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (item['id'] != null) {
                  await _bookingService.updateBooking(item['id'], {'status': 'COMPLETED'});
                  widget.onBookingsChanged();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Machine marked as returned.")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
              child: const Text("Mark as Returned"),
            ),
            _buildReportsSection(item['id']),
          ],
        ),
      ),
    );
  }

  Widget _buildLenderReturnedCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Returned: ${item['title']}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Divider(),
            _buildInfoRow("User", item['renterName']),
            _buildInfoRow("Legal #", item['legalNumber']),
            _buildInfoRow("Rent Dates", item['dates']),
            _buildInfoRow("Revenue", "₹${item['cost']}"),
            _buildReportsSection(item['id']),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(Map<String, dynamic> item, IconData icon, String label) {
    bool isSelected = item['paymentMethod'] == label || (label == "UPI" && item['paymentMethod'] == "Online Payment");
    return GestureDetector(
      onTap: () {
        setState(() {
          item['paymentMethod'] = label;
        });
        widget.onBookingsChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selected $label as your preferred payment method."),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.green[700] : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green[700] : Colors.black54,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myRentals = widget.bookings.where((b) => b['role'] == 'renting').toList();
    
    // Demonstration cards for Lender Mode if real data is empty
    final realLendings = widget.bookings.where((b) => b['role'] == 'lending' || b['lenderName'] == 'Self').toList();
    final List<Map<String, dynamic>> myLendings = isLenderView && realLendings.isEmpty 
      ? [
          {
            'id': 'DEMO_L001',
            'title': 'John Deere 5050E',
            'role': 'lending',
            'status': 'PENDING',
            'cost': 4500.0,
            'renterName': 'Aditya Sharma',
            'userAddress': 'Sector 5, Mandya, KA',
            'dates': 'Jun 05 → Jun 08',
            'legalNumber': 'KA-11-Z-1234',
          },
          {
            'id': 'DEMO_L002',
            'title': 'Mahindra 575 DI',
            'role': 'lending',
            'status': 'ACTIVE',
            'cost': 2400.0,
            'renterName': 'Prakash Raj',
            'userAddress': 'Village Outskirts, Hassan, KA',
            'dates': 'May 30 → Jun 02',
            'legalNumber': 'KA-13-M-5678',
          }
        ]
      : realLendings;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Booking Hub", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Renter Mode"),
                      selected: !isLenderView,
                      onSelected: (val) => setState(() => isLenderView = !val),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("Lender Mode"),
                      selected: isLenderView,
                      onSelected: (val) => setState(() => isLenderView = val),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.green[700],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green[700],
                tabs: isLenderView
                    ? const [Tab(text: "Requested"), Tab(text: "Rented"), Tab(text: "Returned")]
                    : const [Tab(text: "Pending"), Tab(text: "In Use"), Tab(text: "Completed")],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: isLenderView
            ? [
                _buildList(myLendings.where((b) => b['status'] == 'PENDING').toList(), _buildLenderRequestedCard),
                _buildList(myLendings.where((b) => b['status'] == 'ACTIVE').toList(), _buildLenderRentedCard),
                _buildList(myLendings.where((b) => b['status'] == 'COMPLETED').toList(), _buildLenderReturnedCard),
              ]
            : [
                _buildList(myRentals.where((b) => b['status'] == 'PENDING').toList(), _buildRenterPendingCard),
                _buildList(myRentals.where((b) => b['status'] == 'ACTIVE').toList(), _buildRenterInUseCard),
                _buildList(myRentals.where((b) => b['status'] == 'COMPLETED').toList(), _buildRenterCompletedCard),
              ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, Widget Function(Map<String, dynamic>) builder) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No bookings found in this category", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => builder(items[index]),
    );
  }
}
