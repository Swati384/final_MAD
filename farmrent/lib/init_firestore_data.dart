import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInitializer {
  static Future<void> addSampleEquipment() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final collection = db.collection('assets');

    // Categorized list of ~50 equipment items with correct mapping
    List<Map<String, dynamic>> samples = [
      // --- TILLAGE (1-10) ---
      _buildItem('John Deere 5050E', 'Tillage', 'Mahindra Tractor', 1500, 'https://images.unsplash.com/photo-1594750801160-038676d91242?q=80&w=1000', '1 Year', 'High performance tractor for heavy tillage.', 'Me (Lender)', {'power': '50 HP', 'drive': '4WD'}),
      _buildItem('Massey Ferguson 245', 'Tillage', 'Mahindra Tractor', 1200, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Versatile and fuel-efficient.', 'Ganesh Rentals', {'power': '46 HP'}),
      _buildItem('Shaktiman Rotavator', 'Tillage', 'Rotavator', 800, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000', '1 Year', 'Perfect for soil preparation.', 'Me (Lender)', {'width': '7 Feet'}),
      _buildItem('Lemken Disc Plough', 'Tillage', 'Disc Plough', 1000, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '1.5 Years', 'Hard soil specialist.', 'Balaji Agri Fleet', {'discs': '3'}),
      _buildItem('Sonalika Tiger 50', 'Tillage', 'Mahindra Tractor', 1300, 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?q=80&w=1000', '1 Year', 'New gen styling and power.', 'Me (Lender)', {'power': '52 HP'}),
      _buildItem('Fieldking Cultivator', 'Tillage', 'Cultivator', 500, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '3 Years', '9-tyne heavy duty cultivator.', 'Rural Solutions', {'tynes': '9'}),
      _buildItem('Kubota L4508', 'Tillage', 'Mahindra Tractor', 1600, 'https://images.unsplash.com/photo-1594750801160-038676d91242?q=80&w=1000', '1 Year', 'Compact 4WD power.', 'Me (Lender)', {'power': '45 HP'}),
      _buildItem('Mahindra Yuvo 575', 'Tillage', 'Mahindra Tractor', 1450, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Advanced technology for farming.', 'Ganesh Rentals', {'power': '45 HP'}),
      _buildItem('Khedut MB Plough', 'Tillage', 'Disc Plough', 900, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000', '2 Years', 'Reversible plough for efficiency.', 'Me (Lender)', {'type': 'Reversible'}),
      _buildItem('Power Tiller XL', 'Tillage', 'Power Tiller', 700, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '2 Years', 'Best for small plots.', 'Balaji Agri Fleet', {'power': '12 HP'}),

      // --- SOWING (11-20) ---
      _buildItem('John Deere Seed Drill', 'Sowing & Plantation', 'Seed Drill', 1100, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '1.5 Years', 'Precision seed placement.', 'Me (Lender)', {'rows': '13'}),
      _buildItem('Kubota Transplanter', 'Sowing & Plantation', 'Paddy Transplanter', 1800, 'https://images.unsplash.com/photo-1595113316349-9fa4ee24f884?q=80&w=1000', '1 Year', 'High speed rice planting.', 'Green Fields Co.', {'type': '6-Row'}),
      _buildItem('Mahindra Seed Pro', 'Sowing & Plantation', 'Seed Drill', 1000, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '2 Years', 'Automatic depth control.', 'Me (Lender)', {'rows': '11'}),
      _buildItem('Yanmar Paddy Walker', 'Sowing & Plantation', 'Paddy Transplanter', 1500, 'https://images.unsplash.com/photo-1595113316349-9fa4ee24f884?q=80&w=1000', '2 Years', 'Walk-behind efficiency.', 'Rural Solutions', {'type': '4-Row'}),
      _buildItem('Landforce Planter', 'Sowing & Plantation', 'Pneumatic Planter', 2000, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '1 Year', 'Vacuum based seed drill.', 'Me (Lender)', {'precision': 'High'}),
      _buildItem('Tirth Potato Planter', 'Sowing & Plantation', 'Pneumatic Planter', 1400, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '2 Years', 'Specialized potato planting.', 'Ganesh Rentals', {'type': 'Automatic'}),
      _buildItem('Dashmesh Seed Drill', 'Sowing & Plantation', 'Seed Drill', 900, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '3 Years', 'Robust multi-crop drill.', 'Me (Lender)', {'rows': '9'}),
      _buildItem('Gomutra Sprayer Pro', 'Sowing & Plantation', 'Seed Drill', 600, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '1 Year', 'Organic treatment specialized.', 'Balaji Agri Fleet', {'tank': '100L'}),
      _buildItem('VST Shakti Tiller-Seeder', 'Sowing & Plantation', 'Seed Drill', 850, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '2 Years', 'Dual purpose attachment.', 'Me (Lender)', {'power': '13 HP'}),
      _buildItem('National Seed Drill', 'Sowing & Plantation', 'Seed Drill', 950, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=1000', '2 Years', 'Standard 11 row drill.', 'Rural Solutions', {'rows': '11'}),

      // --- HARVESTING (21-35) ---
      _buildItem('Swaraj 855 Harvester', 'Harvesting', 'Combine Harvester', 4500, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Giant for grain harvesting.', 'Me (Lender)', {'cutter': '14ft'}),
      _buildItem('Preet 987 Reaper', 'Harvesting', 'Straw Reaper', 3000, 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?q=80&w=1000', '3 Years', 'Dual blower technology.', 'Balaji Agri Fleet', {'cutter': '7ft'}),
      _buildItem('Kartar 4000', 'Harvesting', 'Combine Harvester', 5000, 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?q=80&w=1000', '1 Year', 'Premium harvester for all crops.', 'Me (Lender)', {'power': '101 HP'}),
      _buildItem('Class Crop Tiger', 'Harvesting', 'Combine Harvester', 4200, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2.5 Years', 'Track type for wet fields.', 'Green Fields Co.', {'type': 'Track'}),
      _buildItem('Standard Thresher', 'Harvesting', 'Thresher', 1200, 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?q=80&w=1000', '3 Years', 'Multi-crop threshing.', 'Me (Lender)', {'capacity': '1000kg/hr'}),
      _buildItem('John Deere Harvester', 'Harvesting', 'Combine Harvester', 5500, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '1 Year', 'Global standard tech.', 'Ganesh Rentals', {'cutter': '16ft'}),
      _buildItem('Vishal Reaper', 'Harvesting', 'Straw Reaper', 2800, 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?q=80&w=1000', '2 Years', 'Fastest straw collection.', 'Me (Lender)', {'power': '40 HP+'}),
      _buildItem('Mahindra Arjun Harvester', 'Harvesting', 'Combine Harvester', 4800, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Robust Arjun series power.', 'Balaji Agri Fleet', {'power': '60 HP'}),
      _buildItem('New Holland Harvester', 'Harvesting', 'Combine Harvester', 5200, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '1.5 Years', 'Efficiency redefined.', 'Me (Lender)', {'cutter': '15ft'}),
      _buildItem('ACE Harvester', 'Harvesting', 'Combine Harvester', 3900, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '4 Years', 'Economical and durable.', 'Rural Solutions', {'cutter': '12ft'}),
      _buildItem('Punni Thresher', 'Harvesting', 'Thresher', 1100, 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?q=80&w=1000', '2 Years', 'Best for wheat and mustard.', 'Me (Lender)', {'type': 'Automatic'}),
      _buildItem('Jagadhri Reaper', 'Harvesting', 'Straw Reaper', 2500, 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?q=80&w=1000', '3 Years', 'Traditional heavy reaper.', 'Ganesh Rentals', {'cutter': '6ft'}),
      _buildItem('Bakhshish Harvester', 'Harvesting', 'Combine Harvester', 4600, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Self-propelled harvester.', 'Me (Lender)', {'power': '75 HP'}),
      _buildItem('Dashmesh Harvester', 'Harvesting', 'Combine Harvester', 4700, 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=1000', '2 Years', 'Punjab standard quality.', 'Balaji Agri Fleet', {'cutter': '14ft'}),
      _buildItem('Guru Nanak Reaper', 'Harvesting', 'Straw Reaper', 2700, 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?q=80&w=1000', '2 Years', 'Reliable straw management.', 'Me (Lender)', {'type': 'Double Blower'}),

      // --- IRRIGATION & PROTECTION (36-50) ---
      _buildItem('Boom Sprayer v2', 'Protection & Irrigation', 'Boom Sprayer', 800, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'High precision spraying.', 'Me (Lender)', {'tank': '500L'}),
      _buildItem('Kirloskar Diesel Pump', 'Protection & Irrigation', 'Water Pump', 500, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '2 Years', 'Reliable water discharge.', 'Rural Solutions', {'power': '5 HP'}),
      _buildItem('Aspee Power Sprayer', 'Protection & Irrigation', 'Power Knapsack Sprayer', 400, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'Backpack sprayer for horticulture.', 'Me (Lender)', {'tank': '20L'}),
      _buildItem('Honda Water Pump', 'Protection & Irrigation', 'Water Pump', 550, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '1.5 Years', 'Quiet and portable.', 'Ganesh Rentals', {'power': '3 HP'}),
      _buildItem('Mitra Boom Sprayer', 'Protection & Irrigation', 'Boom Sprayer', 1200, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'Orchard specialized.', 'Me (Lender)', {'tank': '600L'}),
      _buildItem('Greaves Cotton Pump', 'Protection & Irrigation', 'Water Pump', 450, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '3 Years', 'Heavy duty engine.', 'Balaji Agri Fleet', {'power': '8 HP'}),
      _buildItem('Stihl Mist Blower', 'Protection & Irrigation', 'Power Knapsack Sprayer', 650, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'Professional crop protection.', 'Me (Lender)', {'range': '12m'}),
      _buildItem('Usha Water Pump', 'Protection & Irrigation', 'Water Pump', 480, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '2 Years', 'ISI marked reliability.', 'Rural Solutions', {'power': '5 HP'}),
      _buildItem('Fieldking Boom Sprayer', 'Protection & Irrigation', 'Boom Sprayer', 900, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '2 Years', 'Tractor mounted sprayer.', 'Me (Lender)', {'width': '20ft'}),
      _buildItem('Texmo Submersible', 'Protection & Irrigation', 'Water Pump', 350, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '1 Year', 'Deep well irrigation.', 'Ganesh Rentals', {'depth': '100ft'}),
      _buildItem('KisanKnraft Pump', 'Protection & Irrigation', 'Water Pump', 420, 'https://images.userIds/photo-1582139329536-e7284fece509?q=80&w=1000', '2 Years', 'Compact petrol pump.', 'Me (Lender)', {'power': '1.5 HP'}),
      _buildItem('Falcon Sprayer', 'Protection & Irrigation', 'Power Knapsack Sprayer', 300, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '3 Years', 'Manual + Battery dual mode.', 'Balaji Agri Fleet', {'tank': '16L'}),
      _buildItem('CRI Pump Set', 'Protection & Irrigation', 'Water Pump', 600, 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=1000', '2 Years', 'High efficiency pump.', 'Me (Lender)', {'power': '10 HP'}),
      _buildItem('Captain Sprayer', 'Protection & Irrigation', 'Power Knapsack Sprayer', 450, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'Lightweight design.', 'Rural Solutions', {'tank': '15L'}),
      _buildItem('Agri-Star Boom', 'Protection & Irrigation', 'Boom Sprayer', 1100, 'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?q=80&w=1000', '1 Year', 'Professional wide boom.', 'Me (Lender)', {'width': '30ft'}),
    ];

    for (var sample in samples) {
      final existing = await collection.where('name', isEqualTo: sample['name']).get();
      if (existing.docs.isEmpty) {
        await collection.add(sample);
      }
    }
  }

  static Map<String, dynamic> _buildItem(String name, String cat, String type, double rate, String url, String age, String desc, String owner, Map<String, dynamic> specs) {
    return {
      'name': name,
      'category': cat,
      'type': type,
      'ratePerDay': rate,
      'imageUrl': url,
      'age': age,
      'description': desc,
      'ownerName': owner,
      'rating': 4.5 + (name.length % 5) / 10,
      'reviews': 10 + (name.length * 2),
      'specs': specs,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
