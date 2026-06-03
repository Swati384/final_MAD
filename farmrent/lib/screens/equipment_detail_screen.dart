import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_service.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> equipment;
  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final BookingService _bookingService = BookingService();
  DateTime? _startDate;
  int _duration = 1;
  bool _isBooking = false;

  /*
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
  */

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a start date.")),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final double rate = (widget.equipment['ratePerDay'] ?? 1200).toDouble();
      final double totalCost = rate * _duration;
      final String dates = "${DateFormat('MMM dd').format(_startDate!)}${_duration > 1 ? " → ${DateFormat('MMM dd').format(_startDate!.add(Duration(days: _duration - 1)))}" : ""}";

      await _bookingService.createBooking({
        'title': widget.equipment['name'] ?? "Machinery Rental",
        'role': 'renting',
        'status': 'PENDING',
        'cost': totalCost,
        'renterName': 'Self', // In real app, get from AuthService
        'lenderName': widget.equipment['ownerName'] ?? "Provider",
        'legalNumber': widget.equipment['legalNumber'] ?? 'KA-01-XX-0000',
        'vehicleAge': widget.equipment['age'] ?? '2 Years',
        'lastServiceDate': widget.equipment['lastServiceDate'] ?? 'Recently',
        'lastRentedDate': 'N/A',
        'durationDays': _duration,
        'dates': dates,
        'paymentMethod': 'Paytm',
        'timestamp': DateTime.now(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Booking Requested!"),
            content: const Text("Your request has been sent to the owner. You can track it in the Bookings tab."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eq = widget.equipment;
    final rate = eq['ratePerDay'] ?? 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: eq['imageUrl'] != null && eq['imageUrl'].toString().isNotEmpty
                  ? (eq['imageUrl'].toString().startsWith('assets/')
                      ? Image.asset(eq['imageUrl'], fit: BoxFit.cover)
                      : Image.network(eq['imageUrl'], fit: BoxFit.cover))
                  : Container(color: Colors.grey[200], child: const Icon(Icons.agriculture, size: 80, color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eq['name'] ?? 'Equipment Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(eq['type'] ?? 'Category', style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text("₹$rate/day", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    eq['description'] ?? "This ${eq['name']} is well-maintained and ready for field operations. High performance and fuel efficient for various soil types.",
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text("Specifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSpecRow("Model Year", eq['age'] ?? "2024"),
                  _buildSpecRow("Engine Power", eq['specs']?['power'] ?? "N/A"),
                  _buildSpecRow("Drive Type", eq['specs']?['drive'] ?? "N/A"),
                  _buildSpecRow("Usage Level", "Excellent Condition"),
                  const Divider(height: 40),
                  const Text("Book This Equipment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null ? "Select Start Date" : DateFormat('MMM dd, yyyy').format(_startDate!)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Duration (Days)", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(onPressed: () => setState(() => _duration = _duration > 1 ? _duration - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                          Text("$_duration", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => setState(() => _duration++), icon: const Icon(Icons.add_circle_outline)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isBooking ? null : _confirmBooking,
                      child: _isBooking 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Confirm Booking • ₹${rate * _duration}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
