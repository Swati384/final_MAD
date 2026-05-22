import 'package:flutter/material.dart';
import 'home_hub_tab.dart';
import 'bookings_tab.dart';
import 'payments_tab.dart';
import 'profile_tab.dart';

class CentralDashboardHub extends StatefulWidget {
  const CentralDashboardHub({super.key});

  @override
  State<CentralDashboardHub> createState() => _CentralDashboardHubState();
}

class _CentralDashboardHubState extends State<CentralDashboardHub> {
  int _currentIndex = 0;
  bool isLenderMode = false;

  // Global shared state to simulate live updates across tabs
  List<Map<String, dynamic>> systemBookings = [
    {
      'id': 'B001',
      'title': 'Mahindra Tractor',
      'role': 'renting', // Hired by farmer
      'status': 'ACTIVE',
      'meta': 'Owner: Ramesh G.',
      'dates': 'Apr 15 → Apr 18',
      'cost': 2400,
      'paymentMethod': 'UPI',
      'timestamp': DateTime(2026, 4, 16),
      'route': 'Take State Highway 12 directly to parcel lines to avoid ongoing canal maintenance blockages.',
    },
    {
      'id': 'B002',
      'title': 'Power Tiller',
      'role': 'renting',
      'status': 'COMPLETED',
      'meta': 'By Suresh P. • Apr 10',
      'cost': 1800,
      'paymentMethod': 'UPI',
      'timestamp': DateTime(2026, 4, 10),
      'rated': true,
    },
    {
      'id': 'B003',
      'title': 'Mini Harvester',
      'role': 'renting',
      'status': 'COMPLETED',
      'meta': 'By Venkatesh • Apr 05',
      'cost': 4200,
      'paymentMethod': 'Cash',
      'timestamp': DateTime(2026, 4, 5),
      'rated': false,
    },
    {
      'id': 'B004',
      'title': 'Rotavator Heavy v2',
      'role': 'lending', // Owned fleet item out on lease
      'status': 'ACTIVE',
      'meta': 'Tenant: Gowda Farms',
      'dates': 'May 18 → May 22',
      'cost': 3600,
      'paymentMethod': 'Google Pay',
      'timestamp': DateTime(2026, 5, 19),
      'route': 'Pass through North checkpoint corridor for optimal weight transit verification.',
    }
  ];

  // Simulated Lender Fleet Garage
  List<Map<String, dynamic>> lenderFleet = [
    {'name': 'John Deere Seeder', 'type': 'Sowing', 'status': 'Idle in Garage', 'hp': '55 HP', 'rate': '₹1,500/day'},
    {'name': 'Rotavator Heavy v2', 'type': 'Tillage', 'status': 'Active Lease', 'hp': '40 HP', 'rate': '₹1,200/day'},
  ];

  void toggleRole(bool value) {
    setState(() {
      isLenderMode = value;
    });
  }

  void addBooking(Map<String, dynamic> newBooking) {
    setState(() {
      systemBookings.insert(0, newBooking);
    });
  }

  void addEquipment(Map<String, dynamic> newEquip) {
    setState(() {
      lenderFleet.insert(0, newEquip);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeHubTab(
        isLenderMode: isLenderMode,
        onRoleChanged: toggleRole,
        bookings: systemBookings,
        fleet: lenderFleet,
        onBookingCreated: addBooking,
        onEquipmentAdded: addEquipment,
      ),
      BookingsTab(bookings: systemBookings, onBookingsChanged: () => setState(() {})),
      PaymentsTab(bookings: systemBookings),
      ProfileTab(fleetCount: lenderFleet.length),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Global reusable layout helper for consistent UI headers across all tabs
// Reusable layout helper for consistent UI headers across all tabs
Widget buildGlobalSearchHeader({String title = "FarmRent Hub", Widget? bottomChild}) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.grey),
                const SizedBox(width: 12),
                const Icon(Icons.tune, color: Colors.grey),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.black87, size: 26),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
        if (bottomChild != null) ...[
          const SizedBox(height: 12),
          bottomChild,
        ]
      ],
    ),
  );
}