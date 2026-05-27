import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a new booking in Firestore
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    await _db.collection('bookings').add({
      ...bookingData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Updates a booking's status or other fields
  Future<void> updateBooking(String docId, Map<String, dynamic> updates) async {
    await _db.collection('bookings').doc(docId).update(updates);
  }

  /// Fetches a stream of all bookings (can be filtered by user in real production)
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    return _db.collection('bookings').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id, // Ensure we have the Firestore ID for updates
        };
      }).toList();
    });
  }
}