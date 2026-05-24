import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                          Text("Avoid: $_avoidCrop", style: const TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 13)),
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
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['type'] ?? 'General Purpose',
                                  style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (item['ownerName'] != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  "👤 ${item['ownerName']}",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                )
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(backgroundColor: statusColor, radius: 3.5),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                assetStatus,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Color(0xFFF5F5F5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          "${item['hp'] ?? '45 HP'} Capability",
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      rateDisplay,
                      style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(Icons.edit_note_rounded, size: 16, color: Colors.black.withOpacity(0.54)),
                        label: const Text(
                          "Edit Listing",
                          style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Editing structural variables for: ${item['name']}")),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: Colors.red.shade100),
                          backgroundColor: Colors.red.shade50.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(Icons.pause_circle_outline_rounded, size: 16, color: Colors.red.shade700),
                        label: Text("Pause Visibility", style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Asset visibility status toggled offline for maintenance.")),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicChatConsole() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.green[100], radius: 14, child: const Icon(Icons.psychology, size: 16, color: Color(0xFF4CAF50))),
                  const SizedBox(width: 8),
                  const Text("FarmAI Engine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                ],
              ),
              if (_isAiLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)),
                ),
            ],
          ),
          const Divider(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                bool isAi = chatMessages[index]["role"] == "ai";
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.green[50] : Colors.green[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chatMessages[index]["text"]!,
                      style: TextStyle(color: isAi ? Colors.black87 : Colors.white, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (aiStage == 2) ...[
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.green[50],
              child: Text(
                "📋 Dynamic Machinery Bundle for: $selectedCrop",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: (cropBundles[selectedCrop] ?? [
                  'Utility Tractor (50 HP)',
                  'Multi-Crop Disc Harrow',
                  'Heavy Duty Haulage Trailer'
                ]).map((tool) {
                  bool checked = selectedTools.contains(tool);
                  return CheckboxListTile(
                    title: Text(tool, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    value: checked,
                    dense: true,
                    activeColor: Colors.green[700],
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() {
                      val! ? selectedTools.add(tool) : selectedTools.remove(tool);
                    }),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], minimumSize: const Size(double.infinity, 36)),
              onPressed: selectedTools.isEmpty ? null : () => setState(() {
                aiStage = 3;
                chatMessages.add({"role": "ai", "text": "Analyzing coordinates network... Found premium matches nearby. Choose your logistics contractor:"});
              }),
              child: const Text("Match Local Equipment Providers", style: TextStyle(color: Colors.white, fontSize: 12)),
            )
          ] else if (aiStage == 3) ...[
            ...providersList.map((prov) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(prov['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text("${prov['distance']} km • ⭐ ${prov['rating']}"),
                  trailing: Text("₹${prov['rate']}/day", style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                  onTap: () => setState(() {
                    selectedProvider = prov;
                    aiStage = 4;
                    chatMessages.add({"role": "ai", "text": "Contract compiled! Confirming deployment path with ${prov['name']}."});
                  }),
                ),
              );
            }),
          ] else if (aiStage == 4) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
              child: Text("📝 Contract: ${selectedTools.join(', ')} via ${selectedProvider!['name']}. Total calculated term: 3 Days.", style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    onPressed: () {
                      widget.onBookingCreated({
                        'id': 'B${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        'title': selectedTools.first,
                        'role': 'renting',
                        'status': 'PENDING',
                        'meta': 'Owner: ${selectedProvider!['name']}',
                        'dates': 'May 22 → May 25',
                        'cost': selectedProvider!['rate'] * 3,
                        'paymentMethod': 'UPI',
                        'timestamp': DateTime(2026, 5, 21),
                        'route': 'Transit Path Engaged: Pass through Highway 12 corridor to bypass inner-village load weight parameters.',
                      });
                      setState(() => aiStage = 5);
                    },
                    child: const Text("Confirm & Dispatch", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                    onPressed: () => setState(() {
                      aiStage = 1; selectedTools.clear(); selectedCrop = ""; selectedProvider = null;
                    }),
                    child: const Text("Reset", style: TextStyle(color: Colors.grey))
                )
              ],
            )
          ] else if (aiStage == 5) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text("🚀 Request injected into Deployment Pipeline ledger successfully!", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => setState(() {
                aiStage = 1; selectedTools.clear(); selectedCrop = ""; selectedProvider = null;
                chatMessages.add({"role": "ai", "text": "System cleared. Ask me another farming question!"});
              }),
              child: const Text("Run Another Field Search Sequence", style: TextStyle(fontSize: 11)),
            )
          ],
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: _processCustomUserQuery,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Ask about crops, soil, pests, or tractors...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                backgroundColor: Colors.green[700],
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                  onPressed: () => _processCustomUserQuery(_chatController.text),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    String name = "";
    String type = "Tillage";
    String hpValue = "50";
    String status = "Idle in Garage";
    int rate = 1500;
    String billingUnit = "/day";
    String ownerName = "";
    File? selectedLocalImageFile;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.playlist_add_rounded, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Text("Register Fleet Asset", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final XFile? pickedMedia = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (pickedMedia != null) {
                        setModalState(() {
                          selectedLocalImageFile = File(pickedMedia.path);
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: selectedLocalImageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(selectedLocalImageFile!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 28, color: Colors.green.shade700),
                          const SizedBox(height: 6),
                          const Text("Add Machine Photo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Machine Model Title",
                    hintText: "e.g., John Deere 5050E",
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
                  ),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Owner/Lender Full Name",
                    hintText: "e.g., Ramesh Kumar",
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  onChanged: (v) => ownerName = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: "Category Sub-Tag",
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: ['Tillage', 'Sowing', 'Harvesting', 'Protection']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => type = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: "Initial Availability Status",
                    prefixIcon: Icon(Icons.signal_cellular_alt_rounded, size: 20),
                  ),
                  items: ['Idle in Garage', 'Active Lease', 'Awaiting Delivery']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => status = v!,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Performance Capability (HP)",
                    hintText: "e.g., 50",
                    prefixIcon: Icon(Icons.bolt, size: 20),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => hpValue = v,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Rental Rate (₹)",
                          prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => rate = int.tryParse(v) ?? 1500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: billingUnit,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4)),
                        items: const [
                          DropdownMenuItem(value: '/day', child: Text("/day")),
                          DropdownMenuItem(value: '/hr', child: Text("/hr")),
                        ],
                        onChanged: (v) => setModalState(() => billingUnit = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (name.trim().isNotEmpty) {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Syncing equipment to cloud...")),
                    );

                    String uploadedImageUrl = "";
                    if (selectedLocalImageFile != null) {
                      String fileIdHash = "${DateTime.now().millisecondsSinceEpoch}.jpg";
                      Reference storageBucketPathRef = FirebaseStorage.instance.ref().child('machinery_fleet/$fileIdHash');

                      UploadTask assetUploadTask = storageBucketPathRef.putFile(selectedLocalImageFile!);
                      TaskSnapshot completedTaskSnapshot = await assetUploadTask;
                      uploadedImageUrl = await completedTaskSnapshot.ref.getDownloadURL();
                    }

                    String calibratedHp = hpValue.trim().toUpperCase().contains('HP')
                        ? hpValue.trim().toUpperCase()
                        : '${hpValue.trim()} HP';
                    String compiledRateString = '₹$rate$billingUnit';

                    await FirebaseFirestore.instance.collection('fleet').add({
                      'name': name.trim(),
                      'ownerName': ownerName.trim().isEmpty ? 'Private Owner' : ownerName.trim(),
                      'type': type,
                      'status': status,
                      'hp': calibratedHp,
                      'rate': compiledRateString,
                      'imageUrl': uploadedImageUrl,
                      'distance': 4.5,
                      'created_at': Timestamp.now(),
                    });

                    widget.onEquipmentAdded({
                      'name': name.trim(),
                      'ownerName': ownerName.trim().isEmpty ? 'Private Owner' : ownerName.trim(),
                      'type': type,
                      'status': status,
                      'hp': calibratedHp,
                      'rate': compiledRateString,
                      'imageUrl': uploadedImageUrl,
                      'distance': 4.5,
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Equipment successfully listed in database!")),
                      );
                      Navigator.pop(c);
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cloud pipeline failed: $error")),
                      );
                    }
                  }
                }
              },
              child: const Text("Save Listing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}