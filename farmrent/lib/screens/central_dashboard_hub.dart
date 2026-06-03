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
    },
    // 4. LENDING COMPLETED (For Revenue)
    {
      'id': 'DEMO_B003',
      'title': 'Mahindra Arjun 605',
      'role': 'lending',
      'status': 'COMPLETED',
      'cost': 5000.0,
      'renterName': 'Farmer Ravi',
      'lenderName': 'Me (Lender)',
      'legalNumber': 'KA-01-AX-1122',
      'vehicleAge': '1 Year',
      'durationDays': 2,
      'dates': 'May 15 → May 17',
      'paymentMethod': 'UPI',
      'timestamp': DateTime(2026, 5, 15),
    },
    {
      'id': 'DEMO_B004',
      'title': 'Boom Sprayer v2',
      'role': 'lending',
      'status': 'COMPLETED',
      'cost': 1600.0,
      'renterName': 'Farmer Anil',
      'lenderName': 'Me (Lender)',
      'legalNumber': 'KA-01-AX-3344',
      'vehicleAge': '1 Year',
      'durationDays': 2,
      'dates': 'May 20 → May 22',
      'paymentMethod': 'UPI',
      'timestamp': DateTime(2026, 5, 20),
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
              // --- Tillage Category ---
              {
                'id': 'DEMO_A001',
                'name': 'Mahindra Arjun 605',
                'category': 'Tillage',
                'type': 'Heavy Duty Tractor',
                'ratePerDay': 2500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1594750801160-038676d91242?auto=format&fit=crop&q=80&w=1000',
                'age': '1 Year',
                'description': 'Powerful 60 HP engine, perfect for deep ploughing and heavy tillage. Fuel efficient and reliable.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.9,
                'reviews': 45,
                'distance': 0.5,
                'specs': {'power': '60 HP', 'drive': '4WD', 'lift': '1800 kg'},
              },
              {
                'id': 'DEMO_A006',
                'name': 'Massey Ferguson 245 DI',
                'category': 'Tillage',
                'type': 'Cultivator',
                'ratePerDay': 1500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&q=80&w=1000',
                'age': '2.5 Years',
                'description': 'Versatile tractor with 9-tyne cultivator attachment. Ideal for soil preparation and weed control.',
                'ownerName': 'Ganesh Rentals',
                'isDemo': true,
                'rating': 4.6,
                'reviews': 32,
                'distance': 2.1,
                'specs': {'power': '46 HP', 'width': '7 Feet'},
              },
              // --- Harvesting Category ---
              {
                'id': 'DEMO_A002',
                'name': 'Swaraj 855 FE',
                'category': 'Harvesting',
                'type': 'Combine Harvester',
                'ratePerDay': 4500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?auto=format&fit=crop&q=80&w=1000',
                'age': '2 Years',
                'description': 'High capacity harvester with 14ft cutter bar, ideal for wheat and rice. Minimize grain loss.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.7,
                'reviews': 28,
                'distance': 1.2,
                'specs': {'cutter': '14 Feet', 'power': '52 HP'},
              },
              {
                'id': 'DEMO_A007',
                'name': 'Preet 987 Harvester',
                'category': 'Harvesting',
                'type': 'Straw Reaper',
                'ratePerDay': 3200.0,
                'imageUrl': 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?auto=format&fit=crop&q=80&w=1000',
                'age': '3 Years',
                'description': 'Specialized for straw collection and cleaning after harvesting. Dual blower technology.',
                'ownerName': 'Balaji Agri Fleet',
                'isDemo': true,
                'rating': 4.4,
                'reviews': 18,
                'distance': 4.5,
                'specs': {'cutter': '7 Feet'},
              },
              // --- Sowing & Plantation Category ---
              {
                'id': 'DEMO_A005',
                'name': 'Kubota Paddy Transplanter',
                'category': 'Sowing & Plantation',
                'type': 'Paddy Transplanter',
                'ratePerDay': 1800.0,
                'imageUrl': 'https://images.unsplash.com/photo-1595113316349-9fa4ee24f884?auto=format&fit=crop&q=80&w=1000',
                'age': '3 Years',
                'description': 'Efficient rice planting machine for large scale operations. High speed transplanter.',
                'ownerName': 'Green Fields Co.',
                'isDemo': true,
                'rating': 4.6,
                'reviews': 20,
                'distance': 5.2,
                'specs': {'generic': '6-Row walk-behind type'},
              },
              {
                'id': 'DEMO_A008',
                'name': 'John Deere 13-Row Seed Drill',
                'category': 'Sowing & Plantation',
                'type': 'Seed Drill',
                'ratePerDay': 1100.0,
                'imageUrl': 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=1000',
                'age': '1.5 Years',
                'description': 'High precision seed and fertilizer placement. Durable and easy to calibrate.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.8,
                'reviews': 14,
                'distance': 0.8,
                'specs': {'generic': '13 Rows / Adjustable Depth'},
              },
              // --- Protection & Irrigation Category ---
              {
                'id': 'DEMO_A004',
                'name': 'Boom Sprayer v2',
                'category': 'Protection & Irrigation',
                'type': 'Boom Sprayer',
                'ratePerDay': 800.0,
                'imageUrl': 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?auto=format&fit=crop&q=80&w=1000',
                'age': '1 Year',
                'description': 'High precision boom sprayer for pest control. 500L tank capacity.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.8,
                'reviews': 15,
                'distance': 0.8,
                'specs': {'tank': '500 Liters'},
              },
              {
                'id': 'DEMO_A009',
                'name': 'Kirloskar 5HP Water Pump',
                'category': 'Protection & Irrigation',
                'type': 'Water Pump',
                'ratePerDay': 500.0,
                'imageUrl': 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?auto=format&fit=crop&q=80&w=1000',
                'age': '2 Years',
                'description': 'Reliable diesel water pump for irrigation. High discharge rate and fuel efficient.',
                'ownerName': 'Rural Solutions',
                'isDemo': true,
                'rating': 4.5,
                'reviews': 56,
                'distance': 3.2,
                'specs': {'power': '5 HP', 'generic': 'Diesel Engine'},
              },
              // --- Miscellaneous ---
              {
                'id': 'DEMO_A003',
                'name': 'Power Tiller XL',
                'category': 'Tillage',
                'type': 'Power Tiller',
                'ratePerDay': 1200.0,
                'imageUrl': 'assets/images/equipment/rotavator.png',
                'age': '1.5 Years',
                'description': 'Compact and efficient for small vegetable plots and orchards. Easy to maneuver.',
                'ownerName': 'Balaji Agri Fleet',
                'isDemo': true,
                'rating': 4.5,
                'reviews': 12,
                'distance': 3.5,
                'specs': {'power': '12 HP'},
              },
              {
                'id': 'DEMO_A010',
                'name': 'Universal Seed Drill 11-Row',
                'category': 'Sowing & Plantation',
                'type': 'Seed Drill',
                'ratePerDay': 900.0,
                'imageUrl': 'https://images.unsplash.com/photo-1595841696677-6489ff3f8cd1?auto=format&fit=crop&q=80&w=1000',
                'age': '1 Year',
                'description': 'Precision seed and fertilizer placement for wheat and maize. Durable steel frame.',
                'ownerName': 'Green Fields Co.',
                'isDemo': true,
                'rating': 4.7,
                'reviews': 18,
                'distance': 2.5,
                'specs': {'rows': '11 Rows', 'depth': 'Adjustable'},
              },
              {
                'id': 'DEMO_A011',
                'name': 'High-Volume Diesel Water Pump',
                'category': 'Protection & Irrigation',
                'type': 'Water Pump',
                'ratePerDay': 600.0,
                'imageUrl': 'https://images.unsplash.com/photo-1582139329536-e7284fece509?auto=format&fit=crop&q=80&w=1000',
                'age': '2 Years',
                'description': 'Reliable irrigation solution for large fields. Fuel efficient and portable.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.9,
                'reviews': 24,
                'distance': 0.5,
                'specs': {'power': '7.5 HP', 'discharge': '650 L/min'},
              },
              {
                'id': 'DEMO_A012',
                'name': 'Multi-Crop Thresher Pro',
                'category': 'Harvesting',
                'type': 'Thresher',
                'ratePerDay': 1800.0,
                'imageUrl': 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?auto=format&fit=crop&q=80&w=1000',
                'age': '1.5 Years',
                'description': 'Advanced threshing for wheat, soy, and mustard. Minimal grain breakage.',
                'ownerName': 'Me (Lender)',
                'isDemo': true,
                'rating': 4.8,
                'reviews': 30,
                'distance': 1.1,
                'specs': {'capacity': '800 kg/hr', 'power_req': '35 HP+'},
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