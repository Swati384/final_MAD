import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _imgBBApiKey = '146c72c0b6cc4b28278275b48b8ded29';

  /// Updates user profile data in Firestore
  Future<void> updateProfile({
    required String uid,
    Map<String, dynamic>? updates,
    File? imageFile,
  }) async {
    Map<String, dynamic> data = updates ?? {};

    // 1. Upload new profile picture if provided
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
        data['profileUrl'] = responseData['data']['url'];
      }
    }

    // 2. Persist updates to Firestore
    if (data.isNotEmpty) {
      await _db.collection('users').doc(uid).update(data);
    }
  }

  /// Updates user location coordinates and address string
  Future<void> updateLocation({
    required String uid,
    required double lat,
    required double lng,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).update({
      'latitude': lat,
      'longitude': lng,
      'address': address,
    });
  }

  /// Fetches a live stream of the user's data
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }
}
