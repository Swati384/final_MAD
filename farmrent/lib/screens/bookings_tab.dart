import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

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

class _BookingsTabState extends State<BookingsTab> {
  // WhatsApp style filter system tracking key
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // 1. Core Data Classification Rules
    final allItems = widget.bookings;
    final pendingItems = widget.bookings.where((b) => b['status'] == 'PENDING').toList();
    final lendingItems = widget.bookings.where((b) => b['role'] == 'lending' && b['status'] != 'PENDING').toList();
    final rentingItems = widget.bookings.where((b) => b['role'] == 'renting' && b['status'] != 'PENDING').toList();

    // 2. Select display source list based on active structural segment
    List<Map<String, dynamic>> itemsToDisplay;
    switch (_activeFilter) {
      case 'Pending Outbox':
        itemsToDisplay = pendingItems;
        break;
      case 'Lending (Giving)':
        itemsToDisplay = lendingItems;
        break;
      case 'Renting (Taking)':
        itemsToDisplay = rentingItems;
        break;
      default:
        itemsToDisplay = allItems;
    }

    return Column(
      children: [
        // Native Self-Contained Deployment Pipeline Title Block
        Container(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Deployment Ledger",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // WhatsApp Styled Horizontal Chip Filter Scroller
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All', allItems.length),
                    _buildFilterChip('Pending Outbox', pendingItems.length, highlightColor: Colors.amber[700]),
                    _buildFilterChip('Lending (Giving)', lendingItems.length),
                    _buildFilterChip('Renting (Taking)', rentingItems.length, highlightColor: Colors.blue[700]),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // Main List Rendering Pipeline Space
        Expanded(
          child: itemsToDisplay.isEmpty
              ? _buildEmptyPlaceholder()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itemsToDisplay.length,
            itemBuilder: (context, index) {
              final item = itemsToDisplay[index];

              // Determine layout pattern directly from the runtime object mapping keys
              if (item['status'] == 'PENDING') {
                return _buildPendingCard(item);
              } else if (item['role'] == 'lending') {
                return _buildLendingCard(item);
              } else {
                return _buildRentingCard(item);
              }
            },
          ),
        ),
      ],
    );
  }

  /// WhatsApp Style Filter Badge Interactive Component Builder
  Widget _buildFilterChip(String label, int count, {Color? highlightColor}) {
    bool isSelected = _activeFilter == label;
    Color activePrimaryColor = highlightColor ?? const Color(0xFF2E7D32); // Default Farm Green

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              )
            ]
          ],
        ),
        selected: isSelected,
        selectedColor: activePrimaryColor,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        pressElevation: 0,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _activeFilter = label;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "No logs registered in \"$_activeFilter\"",
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Form Factor Card: Pending Requests Pipeline
  Widget _buildPendingCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber[700], borderRadius: BorderRadius.circular(8)),
                child: Text(item['status'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(item['meta'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 4),
          Text("Revenue Matrix: ₹${item['cost']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
          const Divider(height: 20),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], elevation: 0),
                onPressed: () {
                  item['status'] = 'ACTIVE';
                  item['role'] = 'lending';
                  widget.onBookingsChanged();
                },
                child: const Text("Accept Request", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  widget.bookings.remove(item);
                  widget.onBookingsChanged();
                },
                child: const Text("Decline", style: TextStyle(color: Colors.red, fontSize: 12)),
              )
            ],
          )
        ],
      ),
    );
  }

  /// Form Factor Card: Outbound Fleet Leasing (Lending)
  Widget _buildLendingCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(8)),
                child: Text(item['status'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(item['meta'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 4),
          Text("Revenue Matrix: ₹${item['cost']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          if (item['route'] != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("🗺️ ${item['route']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
            )
          ]
        ],
      ),
    );
  }

  /// Form Factor Card: Farm Equipment Hiring Transactions (Renting)
  Widget _buildRentingCard(Map<String, dynamic> item) {
    bool isActive = item['status'] == 'ACTIVE';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
              Text(
                isActive ? "ACTIVE ✅" : "COMPLETED ⏳",
                style: TextStyle(color: isActive ? Colors.green[700] : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item['meta'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text("Duration: ${item['dates'] ?? 'Closed session'}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text("Cost Outflow: ₹${item['cost']} via ${item['paymentMethod']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          if (isActive) ...[
            if (item['route'] != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("🗺️ ${item['route']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
              ),
            ],
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], elevation: 0),
                    onPressed: () {},
                    child: const Text("Call Fleet Operator", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            )
          ] else ...[
            const SizedBox(height: 6),
            item['rated'] == true
                ? Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 14),
                Text(" Rated 5.0", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
                : TextButton(
              onPressed: () {
                item['rated'] = true;
                widget.onBookingsChanged();
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text("Rate Now ⭐", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
    );
  }
}