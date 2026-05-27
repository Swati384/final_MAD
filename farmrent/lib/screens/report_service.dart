import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Submits a new issue report to Firestore
  Future<void> submitReport({
    required String bookingId,
    required String title,
    required String description,
    required String role,
  }) async {
    try {
      await _db.collection('reports').add({
        'bookingId': bookingId,
        'title': title,
        'description': description,
        'reportedByRole': role,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'OPEN',
      });
      debugPrint("✅ Report saved to Firestore for booking $bookingId");
    } catch (e) {
      debugPrint("❌ Failed to save report: $e");
      // Fallback for local simulation if Firebase is not reachable
    }
  }

  /// Fetches reports associated with a specific booking
  Stream<QuerySnapshot> getReportsForBooking(String bookingId) {
    return _db
        .collection('reports')
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
