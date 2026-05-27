import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'central_dashboard_hub.dart';
import 'otp.dart';
import 'security_settings.dart';
import 'land_plot_management.dart';
import 'garage_fleet_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTab extends StatefulWidget {
  final int fleetCount;
  const ProfileTab({super.key, required this.fleetCount});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isLocating = false;

  Future<void> _updateProfilePhoto(String uid) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      await _userService.updateProfile(uid: uid, imageFile: File(image.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload photo: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleLocationCapture(String uid) async {
    setState(() => _isLocating = true);

    try {
      // 1. Check & Request Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw "Location permission denied by user.";
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw "Location permissions are permanently denied. Please enable them in settings.";
      }

      // 2. Fetch Current GPS Location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Reverse Geocoding
      String readableAddress = "Unknown Location";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          readableAddress = "${place.locality ?? 'City'}, ${place.subAdministrativeArea ?? 'District'} Hub";
        }
      } catch (e) {
        debugPrint("Geocoding failed: $e");
        readableAddress = "Captured: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
      }

      // 4. State Update & Backend Storage
      await _userService.updateLocation(
        uid: uid, 
        lat: position.latitude, 
        lng: position.longitude, 
        address: readableAddress,
      );

      // 5. Navigation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandPlotManagementScreen(
              latitude: position.latitude,
              longitude: position.longitude,
              address: readableAddress,
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Location Error: $e"), backgroundColor: Colors.red[800]),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showEditProfileDialog(String uid, String currentName, String currentAddress) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name", icon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Location/Address", icon: Icon(Icons.location_on)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              await _userService.updateProfile(uid: uid, updates: {
                'fullName': nameController.text.trim(),
                'address': addressController.text.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("SAVE CHANGES"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) return const Center(child: Text("Please log in."));

    return Stack(
      children: [
        Column(
          children: [
            buildGlobalSearchHeader(title: "Partner Portfolio Management"),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _userService.getUserStream(user.uid),
                builder: (context, snapshot) {
                  String name = "Unnamed Farmer";
                  String phone = "";
                  String address = "Set your location";
                  String? profileUrl;
                  String borrowerRating = "4.9";
                  String lenderRating = "4.7";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['fullName'] ?? name;
                    phone = data['phone'] ?? "";
                    address = data['address'] ?? address;
                    profileUrl = data['profileUrl'];
                    borrowerRating = (data['borrowerRating'] ?? "4.9").toString();
                    lenderRating = (data['lenderRating'] ?? "4.7").toString();
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // Interactive Profile Image
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF81C784), width: 2)
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFC8E6C9),
                                backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                child: profileUrl == null
                                    ? Icon(Icons.person, size: 54, color: Colors.green[800])
                                    : null,
                              ),
                            ),
                            if (_isUploading)
                              const Positioned.fill(child: CircularProgressIndicator(color: Colors.green)),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _updateProfilePhoto(user.uid),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50), size: 14),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Accounts Metrics Scoreboard Layout
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                                  onPressed: () => _showEditProfileDialog(user.uid, name, address),
                                )
                              ],
                            ),
                            const Text("Verified Unified Agri-Partner Matrix", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildReputationMetricBadge("Borrower Metrics", "$borrowerRating ⭐"),
                                const SizedBox(width: 10),
                                _buildReputationMetricBadge("Lender Fleet", "$lenderRating ⭐"),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 30, color: Color(0xFFEEEEEE)),

                      // Menu Options
                      _profileMenuTile(
                        Icons.phone_android, 
                        "Authentication Channel", 
                        phone.isEmpty ? "No number linked" : phone,
                        onTap: () {
                          if (phone.isEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const OTPScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const SecuritySettingsScreen()));
                          }
                        },
                      ),
                      _profileMenuTile(
                        Icons.location_on_outlined, 
                        "Geospatial Land Plots", 
                        address,
                        onTap: () => _handleLocationCapture(user.uid),
                      ),
                      _profileMenuTile(
                        Icons.agriculture, 
                        "Active Registered Garage Fleet", 
                        "${widget.fleetCount} items currently managed",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GarageFleetDashboard()),
                          );
                        },
                      ),
                      _profileMenuTile(
                        Icons.help_outline, 
                        "Platform Help Desk & Guidelines", 
                        "Access legal FAQ parameters",
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: "FarmRent Pro",
                            applicationVersion: "1.0.0",
                            children: [
                              const Text("Welcome to FarmRent Help Desk. For support, please contact support@farmrent.com.")
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Secure Session Log Out Button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF5350)),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () async {
                          await authService.signOut();
                        },
                        child: const Text(
                          "Terminate Secure Session (Log Out)",
                          style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      )
                    ],
                  );
                }
              ),
            )
          ],
        ),
        if (_isLocating)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 16),
                      Text("Acquiring GPS coordinates...", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Syncing with geospatial matrix", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReputationMetricBadge(String title, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(score, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _profileMenuTile(IconData leadIcon, String headline, String contextLine, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(leadIcon, color: const Color(0xFF4CAF50), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                  if (contextLine.isNotEmpty) Text(contextLine, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
