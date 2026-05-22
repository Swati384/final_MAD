import 'package:flutter/material.dart';
import 'central_dashboard_hub.dart';

class LangScreen extends StatefulWidget {
  const LangScreen({super.key});

  @override
  State<LangScreen> createState() => _LangScreenState();
}

class _LangScreenState extends State<LangScreen> {
  int? selectedIndex;

  final List<Map<String, String>> languages = [
    {'n': 'ಕನ್ನಡ', 'e': 'Kannada'},
    {'n': 'English', 'e': 'English'},
    {'n': 'हिन्दी', 'e': 'Hindi'},
    {'n': 'తెలుగు', 'e': 'Telugu'},
    {'n': 'தமிழ்', 'e': 'Tamil'},
    {'n': 'മലയാളം', 'e': 'Malayalam'},
    {'n': 'ಮರಾठी', 'e': 'Marathi'},
    {'n': 'ગુજરાતી', 'e': 'Gujarati'},
    {'n': 'ਪੰਜਾਬੀ', 'e': 'Punjabi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Choose Language", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Select your preferred language",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const CentralDashboardHub()));
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[700] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          languages[index]['n']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          languages[index]['e'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}