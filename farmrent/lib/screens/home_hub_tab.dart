import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

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

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Gemini-style authentic conversational logging history setup
  List<Map<String, String>> chatMessages = [
    {
      "role": "ai",
      "text": "Hey there! I am your dedicated Agri-Collaborator. Let's optimize your operations today. Ask me anything about crop planning, soil management, pest controls, or machinery rental setups!"
    }
  ];

  // System Semantic Arrays for Domain Validation Checks
  final List<String> _validAgriTriggers = [
    'grow', 'plant', 'soil', 'mud', 'water', 'irrigate', 'pest', 'bug', 'disease', 'leaf', 'yellow',
    'fertilizer', 'manure', 'yield', 'harvest', 'crop', 'farm', 'field', 'weather', 'rain', 'sunny',
    'tractor', 'rotavator', 'seeder', 'plough', 'tiller', 'harvester', 'sprayer', 'machinery', 'tool',
    'rent', 'lease', 'cost', 'hire', 'price', 'ragi', 'rice', 'paddy', 'tomato', 'vegetable', 'grain'
  ];

  final List<String> _hardCoreOffTopicBlockers = [
    'code', 'python', 'java', 'flutter', 'dart', 'html', 'recipe', 'cook', 'chicken',
    'movie', 'song', 'game', 'history', 'software', 'website', 'write an essay'
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

  /// Core Dynamic Response Engine (Replicates Gemini Processing Style)
  void _processCustomUserQuery(String rawInput) {
    if (rawInput.trim().isEmpty) return;
    String cleanInput = rawInput.trim().toLowerCase();
    _chatController.clear();

    setState(() {
      chatMessages.add({"role": "user", "text": rawInput});
    });
    _scrollToBottom();

    // 🛑 1. STRICT OFF-TOPIC GUARDRAIL CHECK
    for (String blockedWord in _hardCoreOffTopicBlockers) {
      if (cleanInput.contains(blockedWord)) {
        _respondAsAI("I am sorry, but I can only answer questions related to agriculture, crop planning, and equipment rentals.");
        return;
      }
    }

    // 🛡️ 2. AGRI DOMAIN VERIFICATION
    bool isAgriRelated = false;
    for (String trigger in _validAgriTriggers) {
      if (cleanInput.contains(trigger)) {
        isAgriRelated = true;
        break;
      }
    }

    if (!isAgriRelated) {
      _respondAsAI("I am sorry, but I can only answer questions related to agriculture, crop planning, and equipment rentals.");
      return;
    }

    // 🧠 3. GEMINI-STYLE ANALYTICAL COGNITION ENGINE (Contextual Generation)
    String contextualReply = "";

    if (cleanInput.contains('pest') || cleanInput.contains('bug') || cleanInput.contains('disease') || cleanInput.contains('yellow')) {
      contextualReply = "That sounds like a localized pest issue or nutrient deficiency. Yellowing leaves or active bugs require quick treatment. If you are dealing with a horticulture plot like Tomato, I highly recommend checking out our automated Power Sprayer options to protect your yield strategy. Let's initiate a Tomato protection cycle?";
    }
    else if (cleanInput.contains('soil') || cleanInput.contains('water') || cleanInput.contains('mud') || cleanInput.contains('rain')) {
      contextualReply = "Managing ground moisture variability is key. For dense clay soils or high-water periods, a wet field structure is ideal for Rice cultivation. If your soil drainage is faster, dry-land grains like Ragi perform significantly better. What strategy matches your current patch layout?";
    }
    else if (cleanInput.contains('rent') || cleanInput.contains('machinery') || cleanInput.contains('tractor') || cleanInput.contains('price')) {
      contextualReply = "I can definitely handle the asset sourcing logistics for you. Rental parameters are optimized based on your specific crop cycle. Tell me what strategy profile we are tackling today—Ragi, Rice, or Tomato—and I'll pull the perfect machinery options within your radius.";
    }
    // Workflow Engine Stage Adjusters
    else if (cleanInput.contains('ragi')) {
      selectedCrop = 'Ragi';
      setState(() => aiStage = 2);
      contextualReply = "Got it! Let's lock in a Ragi production framework. I've calculated your necessary equipment requirements for optimal tillage and planting. Review the required assets below:";
    }
    else if (cleanInput.contains('rice') || cleanInput.contains('paddy')) {
      selectedCrop = 'Rice';
      setState(() => aiStage = 2);
      contextualReply = "Understood. Switching to a high-yield Rice wetland strategy. This requires high-torque machinery to pull through muddy patches. Here is your customized machinery configuration:";
    }
    else if (cleanInput.contains('tomato')) {
      selectedCrop = 'Tomato';
      setState(() => aiStage = 2);
      contextualReply = "Excellent choice. Horticulture cultivation requires precision protection. Let's build out your Tomato protection and crop support bundle. Check out the setup below:";
    }
    else {
      // General Adaptive Fallback
      contextualReply = "Great point. To give you precise advice and match you with the right equipment setup, tell me which crop timeline we are planning out today: Ragi, Rice, or Tomato?";
    }

    _respondAsAI(contextualReply);
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

  @override
  Widget build(BuildContext context) {
    double totalLenderEarnings = widget.bookings
        .where((b) => b['role'] == 'lending' && b['status'] != 'PENDING')
        .fold(0.0, (sum, item) => sum + item['cost']);

    return Column(
      children: [
        buildGlobalSearchHeader(
          title: "FarmRent Hub",
          bottomChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isLenderMode ? "🔧 Lender Control Space" : "🌾 Farmer Dashboard",
                style: TextStyle(fontSize: 14, color: Colors.green[800], fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Text("Lender View", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Switch(
                    value: widget.isLenderMode,
                    activeColor: Colors.green[700],
                    onChanged: widget.onRoleChanged,
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Weather Status Card
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("32°C", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text("Sunny Day", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          const Icon(Icons.wb_sunny, color: Colors.white, size: 44),
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

              // Crop Advisory Block
              const Text("Crop Advisory", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                          SizedBox(height: 4),
                          Text("Grow: Ragi", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Climate is ideal.", style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.warning, color: Color(0xFFEF5350), size: 18),
                          SizedBox(height: 4),
                          Text("Avoid: Tomato", style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("High pest risk.", style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Real-Time Dynamic Conversational AI Box
              if (!widget.isLenderMode) ...[
                const Text("AI Field Assistant", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 10),
                _buildDynamicChatConsole(),
              ],

              // Fleet Garage Section
              if (widget.isLenderMode) ...[
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1.3, crossAxisSpacing: 10, mainAxisSpacing: 10
                  ),
                  itemCount: widget.fleet.length,
                  itemBuilder: (context, index) {
                    final item = widget.fleet[index];
                    bool isActive = item['status'] == 'Active Lease';
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("${item['hp'] ?? 'N/A'} • ${item['type']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: isActive ? Colors.green[100] : Colors.amber[100], borderRadius: BorderRadius.circular(8)),
                            child: Text(item['status'], style: TextStyle(color: isActive ? Colors.green[800] : Colors.amber[900], fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    );
                  },
                )
              ]
            ],
          ),
        ),
      ],
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
            children: [
              CircleAvatar(backgroundColor: Colors.green[100], radius: 14, child: const Icon(Icons.psychology, size: 16, color: Color(0xFF4CAF50))),
              const SizedBox(width: 8),
              const Text("FarmAI Engine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
            ],
          ),
          const Divider(height: 20),

          // Scrollable Chat Terminal Screen
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

          // Contextual Multi-Asset Form Injections
          if (aiStage == 2) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: (cropBundles[selectedCrop] ?? ['Generic Tractor']).map((tool) {
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
                elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
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

          // Custom Input Area
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
    String name = ""; String type = "Tillage"; String hp = "45 HP"; int rate = 1000;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Register Fleet Asset"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Machine Model Title"), onChanged: (v) => name = v),
            DropdownButtonFormField<String>(
              value: type,
              items: ['Tillage', 'Sowing', 'Harvesting', 'Protection'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => type = v!,
            ),
            TextField(decoration: const InputDecoration(labelText: "Rental Rate (₹/Day)"), keyboardType: TextInputType.number, onChanged: (v) => rate = int.tryParse(v) ?? 1000),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                widget.onEquipmentAdded({'name': name, 'type': type, 'status': 'Idle in Garage', 'hp': hp, 'rate': '₹$rate/day'});
              }
              Navigator.pop(c);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}