import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'fleet_backend_service.dart';

class GarageFleetDashboard extends StatefulWidget {
  const GarageFleetDashboard({super.key});

  @override
  State<GarageFleetDashboard> createState() => _GarageFleetDashboardState();
}

class _GarageFleetDashboardState extends State<GarageFleetDashboard> {
  final FleetBackendService _fleetService = FleetBackendService();
  final Map<String, List<String>> _categoryToEquipmentMap = {
    'Tillage': ['Rotavator', 'Cultivator', 'Disc Plough', 'Power Tiller'],
    'Sowing & Plantation': ['Seed Drill', 'Pneumatic Planter', 'Paddy Transplanter'],
    'Harvesting': ['Combine Harvester', 'Thresher', 'Straw Reaper'],
    'Protection & Irrigation': ['Boom Sprayer', 'Power Knapsack Sprayer', 'Water Pump'],
  };

  void _showAddEquipmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        File? selectedImageFile;
        String equipmentNameInput = "";
        String selectedCategory = 'Tillage';
        String selectedEquipmentType = 'Rotavator';
        String rentalRate = "1200";

        String specPowerHP = "";
        String specDriveType = "4WD";
        String specLiftCapacity = "";
        String specWorkingWidth = "";
        String specBladeCount = "";
        String specTankVolume = "";
        String specGenericSpecs = "";

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<String> equipmentOptions = _categoryToEquipmentMap[selectedCategory] ?? [];

            return Container(
              margin: const EdgeInsets.only(top: 60),
              decoration: const BoxDecoration(
                color: Color(0xFFEDEEE9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.playlist_add_rounded, color: Color(0xFF2E7D32), size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          "Register Fleet Asset",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final ImageSource? selectedSource = await showDialog<ImageSource>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Select Machine Photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            content: const Text("Would you like to snap a new photo or browse your device gallery?"),
                            actions: [
                              TextButton.icon(
                                icon: const Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
                                label: const Text("Photos", style: TextStyle(color: Colors.black87)),
                                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                                label: const Text("Camera", style: TextStyle(color: Colors.black87)),
                                onPressed: () => Navigator.pop(context, ImageSource.camera),
                              ),
                            ],
                          ),
                        );

                        if (selectedSource != null) {
                          final picked = await picker.pickImage(source: selectedSource);
                          if (picked != null) {
                            setModalState(() => selectedImageFile = File(picked.path));
                          }
                        }
                      },
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                          image: selectedImageFile != null
                              ? DecorationImage(image: FileImage(selectedImageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: selectedImageFile == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_outlined, color: Color(0xFF2E7D32), size: 32),
                            SizedBox(height: 8),
                            Text("Add Machine Photo", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                          ],
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Select Classification Category",
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                        border: UnderlineInputBorder(),
                      ),
                      items: _categoryToEquipmentMap.keys
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedCategory = val;
                            selectedEquipmentType = _categoryToEquipmentMap[val]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedEquipmentType,
                      decoration: const InputDecoration(
                        labelText: "What Equipment is This?",
                        prefixIcon: Icon(Icons.build_circle_outlined, size: 20),
                        border: UnderlineInputBorder(),
                      ),
                      items: equipmentOptions
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedEquipmentType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) => equipmentNameInput = val,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.precision_manufacturing_outlined, size: 20),
                        hintText: "Enter Equipment Name / Model (e.g., Mahindra Yuvo 575)",
                        hintStyle: TextStyle(color: Colors.black38),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Equipment Specifications",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 8),
                    () {
                      switch (selectedEquipmentType) {
                        case 'Heavy Duty Tractor':
                        case 'Mahindra Tractor':
                        case 'Power Tiller':
                          return Column(
                            children: [
                              TextField(
                                onChanged: (val) => specPowerHP = val,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.flash_on_rounded, size: 20),
                                  hintText: "Engine Power (e.g., 55 HP)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: specDriveType,
                                decoration: const InputDecoration(
                                  labelText: "Drive Configuration",
                                  prefixIcon: Icon(Icons.grid_4x4_rounded, size: 20),
                                  border: UnderlineInputBorder(),
                                ),
                                items: ['2WD', '4WD'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (val) { if (val != null) setModalState(() => specDriveType = val); },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                onChanged: (val) => specLiftCapacity = val,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.g_mobiledata_rounded, size: 20),
                                  hintText: "Max Hitch Lift Capacity (e.g., 1800 kg)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ],
                          );
                        case 'Rotavator':
                        case 'Cultivator':
                        case 'Disc Plough':
                          return Column(
                            children: [
                              TextField(
                                onChanged: (val) => specWorkingWidth = val,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.straighten_rounded, size: 20),
                                  hintText: "Working Width (e.g., 7 Feet / 42 Tynes)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                onChanged: (val) => specBladeCount = val,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.settings_suggest_outlined, size: 20),
                                  hintText: "Number of Blades (e.g., 36 or 42 Blades)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ],
                          );
                        case 'Boom Sprayer':
                        case 'Power Sprayer':
                        case 'Power Knapsack Sprayer':
                        case 'Water Pump':
                          return Column(
                            children: [
                              TextField(
                                onChanged: (val) => specTankVolume = val,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.opacity_rounded, size: 20),
                                  hintText: "Tank Fluid Capacity (e.g., 500 Liters)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ],
                          );
                        case 'Combine Harvester':
                        case 'Straw Reaper':
                        case 'Thresher':
                          return Column(
                            children: [
                              TextField(
                                onChanged: (val) => specWorkingWidth = val,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.content_cut_rounded, size: 20),
                                  hintText: "Cutter Bar Width (e.g., 14 Feet)",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ],
                          );
                        default:
                          return TextField(
                            onChanged: (val) => specGenericSpecs = val,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.construction_rounded, size: 20),
                              hintText: "Operational Specifications (e.g., Universal Size)",
                              border: UnderlineInputBorder(),
                            ),
                          );
                      }
                    }(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: rentalRate,
                      decoration: const InputDecoration(
                        labelText: "Set Base Daily Rental Fee",
                        prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                        border: UnderlineInputBorder(),
                      ),
                      items: ['800', '1000', '1200', '1400', '1600', '2000', '2500']
                          .map((val) => DropdownMenuItem(value: val, child: Text("₹$val per day")))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => rentalRate = val);
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008736),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (equipmentNameInput.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter a valid equipment name.")),
                              );
                              return;
                            }

                            Map<String, String> specsPayload = {
                              if (selectedEquipmentType.contains('Tractor') || selectedEquipmentType.contains('Tiller')) ...{
                                "power": specPowerHP, "drive": specDriveType, "lift": specLiftCapacity
                              } else if (selectedEquipmentType.contains('Rotavator') || selectedEquipmentType.contains('Cultivator') || selectedEquipmentType.contains('Plough')) ...{
                                "width": specWorkingWidth, "blades": specBladeCount
                              } else if (selectedEquipmentType.contains('Sprayer') || selectedEquipmentType.contains('Pump')) ...{
                                "tank": specTankVolume
                              } else if (selectedEquipmentType.contains('Harvester') || selectedEquipmentType.contains('Reaper') || selectedEquipmentType.contains('Thresher')) ...{
                                "cutter": specWorkingWidth
                              } else ...{
                                "generic": specGenericSpecs
                              }
                            };

                            try {
                              final double parsedRate = double.tryParse(rentalRate) ?? 1200.0;
                              await _fleetService.deployNewAsset(
                                equipmentName: equipmentNameInput,
                                category: selectedCategory,
                                type: selectedEquipmentType,
                                ratePerDay: parsedRate,
                                imageFile: selectedImageFile,
                                preparedSpecs: specsPayload,
                              );
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: Colors.red.shade800, content: Text("Database Pipeline Failure: $e")),
                                );
                              }
                            }
                          },
                          child: const Text("Deploy Asset", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteEquipment(String? docId) async {
    if (docId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Equipment?"),
        content: const Text("This will permanently remove the machinery from your garage and the platform. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("REMOVE"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _fleetService.deleteAsset(docId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Equipment removed successfully.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to remove equipment: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Garage Fleet Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () => _showAddEquipmentDialog(context),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fleetService.getFleetStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          final allFleet = snapshot.data ?? [];
          final fleet = allFleet.where((item) => item['ownerName'] == 'Me (Lender)').toList();

          if (fleet.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.agriculture_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Your garage is empty", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddEquipmentDialog(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Add Your First Machine", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fleet.length,
            itemBuilder: (context, index) {
              final item = fleet[index];
              return _buildGarageItemCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildGarageItemCard(Map<String, dynamic> item) {
    String rateDisplay = "₹${(item['ratePerDay'] ?? 1200).toString()}/day";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Image.network(
                item['imageUrl'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unnamed Machinery',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                          Text(
                            item['type'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _deleteEquipment(item['id']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rateDisplay,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      item['category'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
