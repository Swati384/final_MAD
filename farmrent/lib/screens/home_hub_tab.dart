import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Connects directly to the backend file you created
import 'fleet_backend_service.dart';

class HomeHubTab extends StatefulWidget {
  final bool isLenderMode;
  final ValueChanged<bool> onRoleChanged;
  final List<Map<String, dynamic>> bookings;
  final List<Map<String, dynamic>> fleet;
  final ValueChanged<Map<String, dynamic>> onBookingCreated;
  final ValueChanged<Map<String, dynamic>> onEquipmentAdded;

  const HomeHubTab({
    super.key,
    required this.isLenderMode,
    required this.onRoleChanged,
    required this.bookings,
    required this.fleet,
    required this.onBookingCreated,
    required this.onEquipmentAdded,
  });

  @override
  State<HomeHubTab> createState() => _HomeHubTabState();
}

class _HomeHubTabState extends State<HomeHubTab> {
  int aiStage = 1;
  String selectedCrop = "";
  List<String> selectedTools = [];
  Map<String, dynamic>? selectedProvider;
  bool _isAiLoading = false;

  // Real-Time Dynamic Climate Parameters
  String _currentTemperature = "28°C";
  String _currentConditionText = "Partly Sunny";
  IconData _weatherIcon = Icons.cloud_queue_rounded;
  Color _weatherCardColor = const Color(0xFF4FC3F7);

  // Fully Reactive Crop Advisory State Fields
  String _recommendedCrop = "Ragi";
  String _recommendedReason = "Sunny intervals favor soil aeration.";
  String _avoidCrop = "Tomato";
  String _avoidReason = "High ambient heat risks premature wilting.";

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Search, Filter, and Query Execution States
  bool _isSearchVisible = false;
  final TextEditingController _searchQueryController = TextEditingController();
  String _searchString = "";
  double _maxPriceFilter = 5000.0;
  double _maxDistanceFilter = 50.0;

  List<Map<String, String>> chatMessages = [
    {
      "role": "ai",
      "text": "Hey there! I am your dedicated Agri-Collaborator. Let's optimize your operations today. Ask me anything about crop planning, soil management, pest controls, or machinery rental setups!"
    }
  ];

  final Map<String, List<String>> cropBundles = {
    'Ragi': ['Mahindra Tractor', 'Compatible Rotavator', 'Specialized Seed Drill'],
    'Rice': ['Heavy Duty Tractor', 'Mud puddler wheel', 'High-Capacity Harvester'],
    'Tomato': ['Power Sprayer', 'Mini Tiller Attachment', 'Staking Installer'],
  };

  final List<Map<String, dynamic>> providersList = [
    {'name': 'Ganesh Rentals', 'distance': 1.2, 'rating': 4.9, 'reviews': 120, 'rate': 1200},
    {'name': 'Balaji Agri Fleet', 'distance': 2.4, 'rating': 4.7, 'reviews': 85, 'rate': 1400},
  ];

  // Mapping categories to specialized sub-machinery types
  final Map<String, List<String>> _categoryToEquipmentMap = {
    'Tillage': ['Rotavator', 'Cultivator', 'Disc Plough', 'Power Tiller'],
    'Sowing & Plantation': ['Seed Drill', 'Pneumatic Planter', 'Paddy Transplanter'],
    'Harvesting': ['Combine Harvester', 'Thresher', 'Straw Reaper'],
    'Protection & Irrigation': ['Boom Sprayer', 'Power Knapsack Sprayer', 'Water Pump'],
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentClimateData();
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentClimateData() {
    setState(() {
      _currentTemperature = "28°C";
      _currentConditionText = "Partly Sunny";
      _weatherIcon = Icons.cloud_queue_rounded;
      _weatherCardColor = const Color(0xFF4FC3F7);

      if (_currentConditionText.contains("Sunny") || _currentConditionText.contains("Clear")) {
        _recommendedCrop = "Ragi & Maize";
        _recommendedReason = "Optimal sunlight accelerates photosynthesis.";
        _avoidCrop = "Leafy Greens";
        _avoidReason = "High evaporation rates cause moisture stress.";
      } else {
        _recommendedCrop = "Rice Paddy";
        _recommendedReason = "Sustained damp cloud covers optimize soil absorption.";
        _avoidCrop = "Cotton Sprouts";
        _avoidReason = "Excess root moisture limits nitrogen pickup.";
      }
    });
  }

  void _processCustomUserQuery(String rawInput) async {
    if (rawInput.trim().isEmpty) return;
    String cleanInput = rawInput.trim().toLowerCase();
    _chatController.clear();

    setState(() {
      chatMessages.add({"role": "user", "text": rawInput});
      _isAiLoading = true;
    });
    _scrollToBottom();

    bool wantsToRent = cleanInput.contains('rent') ||
        cleanInput.contains('book') ||
        cleanInput.contains('hire') ||
        cleanInput.contains('need equipment');

    if (wantsToRent) {
      String detectedCrop = "Generic Crop";
      RegExp cropRegex = RegExp(r'(?:for|rent|book|grow|cultivate)\s+([a-zA-Z]+)');
      Iterable<Match> matches = cropRegex.allMatches(cleanInput);

      if (matches.isNotEmpty) {
        String matchText = matches.first.group(1)!;
        if (matchText != 'rent' && matchText != 'book' && matchText != 'hire') {
          detectedCrop = matchText[0].toUpperCase() + matchText.substring(1);
        }
      } else {
        for (String crop in ['ragi', 'rice', 'tomato', 'wheat', 'corn', 'maize', 'cotton', 'mango']) {
          if (cleanInput.contains(crop)) {
            detectedCrop = crop[0].toUpperCase() + crop.substring(1);
            break;
          }
        }
      }

      selectedCrop = detectedCrop;
      selectedTools.clear();
      setState(() => aiStage = 2);
    } else {
      setState(() => aiStage = 1);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: 'AIzaSyDQs0C2qHIuoohZI_ikXn0yfe7DEQdzyN8',
      );

      final contextualPrompt =
          "SYSTEM INSTRUCTIONS:\n"
          "You are the intelligent, conversational Gemini AI Assistant built into the FarmRent app. "
          "Your tone is professional, supportive, witty, and deeply analytical—exactly like an expert agronomy peer.\n"
          "CRITICAL SCOPE RULE: You can answer ANY question as long as it relates to agriculture, soil biology, weather patterns, crop diseases, fertilizer calculations, tractor specifications, or machinery operations. "
          "However, if the user asks about anything completely unrelated (like coding, software engineering, movies, pop culture, non-farming history, or cooking recipes), you must refuse to answer. Respond exactly with this phrase: "
          "\"I am sorry, but I can only answer questions related to agriculture, crop planning, and equipment rentals.\"\n\n"
          "USER INPUT:\n$rawInput";

      final response = await model.generateContent([Content.text(contextualPrompt)]);

      setState(() {
        chatMessages.add({"role": "ai", "text": response.text ?? "Error generating advisory sequence."});
        _isAiLoading = false;
      });
    } catch (e) {
      debugPrint("=================================================");
      debugPrint("🚨 DETAILED SYSTEM FAILURE TRACE: $e");
      debugPrint("=================================================");

      _respondAsAI("Connection error: Unable to compute model pipeline parameters.");
      setState(() => _isAiLoading = false);
    }
    _scrollToBottom();
  }

  void _respondAsAI(String text) {
    setState(() {
      chatMessages.add({"role": "ai", "text": text});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Refine Fleet Search",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _maxPriceFilter = 5000.0;
                            _maxDistanceFilter = 50.0;
                          });
                        },
                        child: const Text("Reset All", style: TextStyle(color: Colors.grey)),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Max Price Limit", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text("₹${_maxPriceFilter.toInt()}/day", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _maxPriceFilter,
                    min: 500.0,
                    max: 5000.0,
                    divisions: 9,
                    activeColor: Colors.green.shade700,
                    inactiveColor: Colors.green.shade100,
                    onChanged: (val) {
                      setModalState(() => _maxPriceFilter = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Max Distance Radius", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text("${_maxDistanceFilter.toInt()} km", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _maxDistanceFilter,
                    min: 5.0,
                    max: 50.0,
                    divisions: 9,
                    activeColor: Colors.green.shade700,
                    inactiveColor: Colors.green.shade100,
                    onChanged: (val) {
                      setModalState(() => _maxDistanceFilter = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Apply Logistics Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _triggerVoiceSearchInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic, color: Colors.green.shade200),
            const SizedBox(width: 12),
            const Text("Listening for machine models or owners..."),
          ],
        ),
        backgroundColor: Colors.green.shade900,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFleet() {
    return widget.fleet.where((item) {
      final nameMatches = (item['name'] ?? '').toString().toLowerCase().contains(_searchString.toLowerCase());
      final ownerMatches = (item['ownerName'] ?? '').toString().toLowerCase().contains(_searchString.toLowerCase());

      final rawRateString = (item['rate'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
      final parsedRate = double.tryParse(rawRateString) ?? 1200.0;
      final distanceValue = double.tryParse((item['distance'] ?? '2.0').toString()) ?? 2.0;

      return (nameMatches || ownerMatches) &&
          (parsedRate <= _maxPriceFilter) &&
          (distanceValue <= _maxDistanceFilter);
    }).toList();
  }

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

        // Local state hooks for tracking dynamic specs within the sheet
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

                    // Asset Image Capture Field Box with Camera/Photos Option Dialog Selector
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();

                        // Display an AlertDialog to ask the user for their media source
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

                        // If the user picked an option, trigger the image picker
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

                    // Primary Category Dropdown Selection
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

                    // Dependent Equipment Sub-Type Dropdown Selection
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

                    // Unified Model and Equipment Title Text Field
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

                    // Custom Contextual Form Engine Pipeline
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
                        case 'Compatible Rotavator':
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
                        case 'High-Capacity Harvester':
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

                    // Dynamic Pricing Multiplier Selector
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

                    // Form Action Controls
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
                            // Validate that a name has been input before running pipelines
                            if (equipmentNameInput.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter a valid equipment name.")),
                              );
                              return;
                            }

                            // Pack contextual fields securely to dictionary map array schemas
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

                              // Fire data payload stream directly to Firebase storage pipelines
                              await FleetBackendService().deployNewAsset(
                                equipmentName: equipmentNameInput,
                                category: selectedCategory,
                                type: selectedEquipmentType,
                                ratePerDay: parsedRate,
                                imageFile: selectedImageFile,
                                preparedSpecs: specsPayload,
                              );

                              // Build local representation map matching user grid schema targets
                              Map<String, dynamic> newAssetData = {
                                "name": equipmentNameInput,
                                "category": selectedCategory,
                                "type": selectedEquipmentType,
                                "rate": "₹${parsedRate.toInt()}/day",
                                "distance": "0.0",
                                "ownerName": "Me (Lender)",
                                "specs": specsPayload,
                                "imagePath": selectedImageFile?.path ?? "",
                              };

                              // Pass up to parent component stream state loops to update UI instantly
                              widget.onEquipmentAdded(newAssetData);

                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: Colors.red.shade800, content: Text("Database Pipeline Failure: $e")),
                              );
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
  @override
  Widget build(BuildContext context) {
    double totalLenderEarnings = widget.bookings
        .where((b) => b['role'] == 'lending' && b['status'] != 'PENDING')
        .fold(0.0, (sum, item) => sum + item['cost']);

    final filteredFleetList = _getFilteredFleet();

    return Column(
      children: [
        // App Bar Header Design
        Container(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "FarmRent Pro",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              foreground: Paint()..shader = const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                          const Text(
                            "Smart Yield Logistics",
                            style: TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                            _isSearchVisible ? Icons.search_off_outlined : Icons.search_rounded,
                            color: _isSearchVisible ? Colors.red.shade700 : Colors.green.shade800
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchVisible = !_isSearchVisible;
                            if (!_isSearchVisible) {
                              _searchQueryController.clear();
                              _searchString = "";
                            }
                          });
                        },
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_none_rounded, color: Colors.grey.shade700),
                            onPressed: () {},
                          ),
                          const Positioned(
                            right: 12,
                            top: 12,
                            child: CircleAvatar(radius: 4, backgroundColor: Colors.orange),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              if (_isSearchVisible) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchQueryController,
                          style: const TextStyle(fontSize: 14),
                          onChanged: (val) {
                            setState(() => _searchString = val);
                          },
                          decoration: const InputDecoration(
                            hintText: "Search by model name or provider...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.mic_none_rounded, color: Colors.green.shade700, size: 20),
                        onPressed: _triggerVoiceSearchInput,
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      IconButton(
                        icon: Icon(Icons.tune_rounded, color: Colors.green.shade700, size: 20),
                        onPressed: _showFilterBottomSheet,
                      ),
                    ],
                  ),
                ),
                if (_searchString.isNotEmpty || _maxPriceFilter < 5000 || _maxDistanceFilter < 50)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4),
                    child: Text(
                      "Showing matches filtered by query constraints (${filteredFleetList.length} found)",
                      style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isLenderMode ? "🔧 Lender Control Space" : "🌾 Farmer Dashboard",
                    style: TextStyle(fontSize: 13, color: Colors.green[800], fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        "Lender Mode",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: widget.isLenderMode,
                          activeColor: Colors.green[700],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: widget.onRoleChanged,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _weatherCardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _weatherCardColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentTemperature,
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        _currentConditionText,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                      const SizedBox(width: 2),
                                      const Text("Bengaluru", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(_weatherIcon, color: Colors.white, size: 40),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isLenderMode) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 82,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Fleet Revenue", style: TextStyle(color: Colors.black54, fontSize: 11)),
                            Text("₹${totalLenderEarnings.toStringAsFixed(0)}", style: TextStyle(color: Colors.green[900], fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ]
                ],
              ),
              const SizedBox(height: 20),
              const Text("Climate Crop Advisory", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minHeight: 105),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                          const SizedBox(height: 4),
                          Text("Grow: $_recommendedCrop", style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(_recommendedReason, style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minHeight: 105),
                      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning, color: Color(0xFFEF5350), size: 18),
                          const SizedBox(height: 4),
                          Text("Avoid: $_avoidCrop", style: const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(_avoidReason, style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!widget.isLenderMode) ...[
                const Text("AI Field Assistant", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 10),
                _buildDynamicChatConsole(),
              ],
              if (widget.isLenderMode) ...[
                _buildGarageSection(filteredFleetList),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicChatConsole() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 6,
                  backgroundColor: _isAiLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Gemini Smart Assistant Pipeline",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (aiStage == 2) ...[
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select machinery bundle tools for cultivating $selectedCrop:",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (cropBundles[selectedCrop] ?? ['Standard Tractor', 'Universal Tiller']).map((tool) {
                      final isChosen = selectedTools.contains(tool);
                      return ChoiceChip(
                        label: Text(
                          tool,
                          style: TextStyle(
                            fontSize: 11,
                            color: isChosen ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isChosen,
                        selectedColor: Colors.green,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTools.add(tool);
                            } else {
                              selectedTools.remove(tool);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (selectedTools.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() => aiStage = 3);
                        },
                        child: const Text("Proceed to Providers ➔", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              ),
            ),
          ],
          Container(
            height: 250,
            color: Colors.white,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green.shade600 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      textAlign: isUser ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Ask about seeds, soil, or planning...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: _processCustomUserQuery,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.green),
                  onPressed: () => _processCustomUserQuery(_chatController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarageSection(List<Map<String, dynamic>> filteredFleetList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("My Equipment Garage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50), size: 28),
              onPressed: () => _showAddEquipmentDialog(context),
            )
          ],
        ),
        const SizedBox(height: 10),
        filteredFleetList.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text("No machinery matches current search metrics.", style: TextStyle(color: Colors.black38, fontSize: 13)),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredFleetList.length,
          itemBuilder: (context, index) {
            return _buildGarageItemCard(filteredFleetList[index]);
          },
        ),
      ],
    );
  }

  Widget _buildGarageItemCard(Map<String, dynamic> item) {
    Color statusColor = Colors.grey.shade600;
    Color statusBg = Colors.grey.shade100;
    String assetStatus = item['status'] ?? 'Idle in Garage';

    if (assetStatus.contains('Active Lease') || assetStatus.contains('Working')) {
      statusColor = const Color(0xFF2E7D32);
      statusBg = const Color(0xFFE8F5E9);
    } else if (assetStatus.contains('Awaiting') || assetStatus.contains('Scheduled')) {
      statusColor = const Color(0xFFE65100);
      statusBg = const Color(0xFFFFF3E0);
    }

    String rateDisplay = item['rate'] != null ? item['rate'].toString() : "₹1,200/day";
    if (!rateDisplay.contains('₹')) rateDisplay = "₹$rateDisplay/day";

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
              child: item['imageUrl'].toString().startsWith('/') || item['imageUrl'].toString().contains(':/')
                  ? Image.file(
                File(item['imageUrl']),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              )
                  : Image.network(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unnamed Machinery',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  assetStatus,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rateDisplay,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item['distance'] ?? '2.0'} km away",
                            style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.48)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item['capacity'] != null && item['capacity'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Specs: ${item['capacity']}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${item['rating'] ?? '5.0'}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${item['reviews'] ?? '0'} reviews)",
                          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.48)),
                        ),
                      ],
                    ),
                    Text(
                      "Owner: ${item['ownerName'] ?? 'Verified Partner'}",
                      style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.48)),
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