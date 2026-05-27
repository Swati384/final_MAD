import 'package:flutter/material.dart';
import 'home_hub_tab.dart';
import 'bookings_tab.dart';
import 'payments_tab.dart';
import 'profile_tab.dart';
import 'booking_service.dart';
import 'fleet_backend_service.dart';

class CentralDashboardHub extends StatefulWidget {
  const CentralDashboardHub({super.key});

  @override
  State<CentralDashboardHub> createState() => _CentralDashboardHubState();
}

class _CentralDashboardHubState extends State<CentralDashboardHub> {
  int _currentIndex = 0;
  bool isLenderMode = false;
  
  final BookingService _bookingService = BookingService();
  final FleetBackendService _fleetService = FleetBackendService();

  void toggleRole(bool value) {
    setState(() {
      isLenderMode = value;
    });
  }

  void addBooking(Map<String, dynamic> newBooking) async {
    await _bookingService.createBooking(newBooking);
  }

  void addEquipment(Map<String, dynamic> newEquip) {
    // Already handled by FleetBackendService inside HomeHubTab
  }

  final List<Map<String, dynamic>> demoBookings = [
    // 1. PENDING (Renter) / REQUESTED (Lender)
    {
      'id': 'DEMO_B005',
      'title': 'John Deere Tractor 5050E',
      'role': 'renting', 
      'status': 'PENDING',
      'cost': 4500.0,
      'renterName': 'Rajesh Kumar',
      'lenderName': 'Ganesh Rentals',
      'legalNumber': 'KA-01-AX-4567',
      'vehicleAge': '2 Years',
      'lastServiceDate': 'Apr 10, 2026',
      'lastRentedDate': 'May 05, 2026',
      'userAddress': 'House #45, Mandya Village, Karnataka',
      'durationDays': 3,
      'dates': 'May 28 → May 31',
      'paymentMethod': 'Select Method',
      'lenderPhone': '9112345678',
      'timestamp': DateTime(2026, 5, 10),
    },
    // 2. ACTIVE (Renter "In Use" / Lender "Rented")
    {
      'id': 'DEMO_B001',
      'title': 'Mahindra Tractor 575 DI',
      'role': 'renting', 
      'status': 'ACTIVE',
      'cost': 2400.0,
      'renterName': 'Suresh Singh',
      'lenderName': 'Ramesh G.',
      'legalNumber': 'KA-09-BN-8899',
      'vehicleAge': '3 Years',
      'lastServiceDate': 'Feb 15, 2026',
      'lastRentedDate': 'Apr 10, 2026',
      'userAddress': 'Plot 12, Hassan Road, Tumakuru',
      'durationDays': 4,
      'dates': 'May 24 → May 28',
      'paymentMethod': 'UPI',
      'lenderPhone': '9876543210',
      'timestamp': DateTime(2026, 5, 20),
    },
    // 3. COMPLETED (Renter "Completed" / Lender "Returned")
    {
      'id': 'DEMO_B002',
      'title': 'Power Tiller Multi',
      'role': 'renting',
      'status': 'COMPLETED',
      'cost': 1800.0,
      'renterName': 'Venkatesh',
      'lenderName': 'Suresh P.',
      'legalNumber': 'KA-05-MM-1234',
      'vehicleAge': '1.5 Years',
      'lastServiceDate': 'Mar 20, 2026',
      'lastRentedDate': 'May 12, 2026',
      'userAddress': 'Gowda Estate, Sector 4, Mysore',
      'durationDays': 2,
      'dates': 'Apr 10 → Apr 12',
      'paymentMethod': 'Cash on Delivery',
      'lenderPhone': '9443322110',
      'timestamp': DateTime(2026, 4, 10),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _bookingService.getBookingsStream(),
      builder: (context, bookingSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fleetService.getFleetStream(),
          builder: (context, fleetSnapshot) {
            // Combine real Firestore data with Demo data for presentation
            final List<Map<String, dynamic>> systemBookings = [
              ...demoBookings,
              ...(bookingSnapshot.data ?? []),
            ];
            final List<Map<String, dynamic>> lenderFleet = [
              // Demo equipment for Lender Mode
              {
                'id': 'DEMO_A001',
                'name': 'Mahindra Arjun 605',
                'category': 'Tillage',
                'type': 'Heavy Duty Tractor',
                'ratePerDay': 2500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1594750801160-038676d91242?auto=format&fit=crop&q=80&w=1000',
                'age': '1 Year',
                'description': 'Powerful 60 HP engine, perfect for deep ploughing and heavy tillage.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.9,
                'reviews': 45,
                'distance': 0.5,
              },
              {
                'id': 'DEMO_A002',
                'name': 'Swaraj 855 FE',
                'category': 'Harvesting',
                'type': 'Combine Harvester',
                'ratePerDay': 4500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?auto=format&fit=crop&q=80&w=1000',
                'age': '2 Years',
                'description': 'High capacity harvester with 14ft cutter bar, ideal for wheat and rice.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.7,
                'reviews': 28,
                'distance': 1.2,
              },
              {
                'id': 'DEMO_A003',
                'name': 'Power Tiller XL',
                'category': 'Tillage',
                'type': 'Power Tiller',
                'ratePerDay': 1200.0,
                'imageUrl': 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=1000',
                'age': '1.5 Years',
                'description': 'Compact and efficient for small vegetable plots and orchards.',
                'ownerName': 'Balaji Agri Fleet', // Not mine
                'isDemo': true,
                'rating': 4.5,
                'reviews': 12,
                'distance': 3.5,
              },
              {
                'id': 'DEMO_A004',
                'name': 'Boom Sprayer v2',
                'category': 'Protection & Irrigation',
                'type': 'Boom Sprayer',
                'ratePerDay': 800.0,
                'imageUrl': 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?auto=format&fit=crop&q=80&w=1000',
                'age': '1 Year',
                'description': 'High precision boom sprayer for pest control.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.8,
                'reviews': 15,
                'distance': 0.8,
              },
              {
                'id': 'DEMO_A005',
                'name': 'Kubota Paddy Transplanter',
                'category': 'Sowing & Plantation',
                'type': 'Paddy Transplanter',
                'ratePerDay': 1800.0,
                'imageUrl': 'https://images.unsplash.com/photo-1595113316349-9fa4ee24f884?auto=format&fit=crop&q=80&w=1000',
                'age': '3 Years',
                'description': 'Efficient rice planting machine for large scale operations.',
                'ownerName': 'Green Fields Co.',
                'isDemo': true,
                'rating': 4.6,
                'reviews': 20,
                'distance': 5.2,
              },
              ...(fleetSnapshot.data ?? []),
            ];

            final List<Widget> tabs = [
              HomeHubTab(
                isLenderMode: isLenderMode,
                onRoleChanged: toggleRole,
                bookings: systemBookings,
                fleet: lenderFleet,
                onBookingCreated: addBooking,
                onEquipmentAdded: (equip) => setState(() {}),
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
        );
      }
    );
  }
}

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
          color: Colors.black.withValues(alpha: 0.05),
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