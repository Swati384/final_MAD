import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FleetBackendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔑 Your live ImgBB API Key
  final String _imgBBApiKey = '146c72c0b6cc4b28278275b48b8ded29';

  /// Deploys asset to ImgBB & Firestore, and returns the generated Document ID
  Future<String> deployNewAsset({
    required String equipmentName,
    required String category,
    required String type,
    required double ratePerDay,
    required File? imageFile,
    required Map<String, String> preparedSpecs,
  }) async {
    String imageUrl = '';

    // 1. Upload to ImgBB if an image file is provided
    if (imageFile != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBApiKey'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        imageUrl = responseData['data']['url']; // Public URL hosted by ImgBB!
      } else {
        throw Exception('ImgBB Upload Failed: ${response.body}');
      }
    }

    // 2. Save everything to Firestore (Free Tier)
    DocumentReference docRef = await _db.collection('assets').add({
      'name': equipmentName,
      'category': category,
      'type': type,
      'ratePerDay': ratePerDay,
      'imageUrl': imageUrl,
      'specs': preparedSpecs,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Return the auto-generated Firestore ID so the UI can attach it to the local state map
    return docRef.id;
  }

  /// Removes an asset directly from Firestore using its Document ID
  Future<void> deleteAsset(String docId) async {
    await _db.collection('assets').doc(docId).delete();
  }
}