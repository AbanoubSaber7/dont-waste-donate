import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Donation {
  final String id;
  final String userId;
  final String category;
  final String description;
  final String? imageUrl;
  final LatLng? location;
  final DateTime date;
  final String status; // e.g., 'pending', 'accepted', 'completed'

  Donation({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    this.imageUrl,
    this.location,
    required this.date,
    required this.status,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    LatLng? location;
    if (data['location'] != null) {
      Map locData = data['location'] as Map;
      location = LatLng(locData['latitude'], locData['longitude']);
    }
    return Donation(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      location: location,
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'location': location != null ? {'latitude': location!.latitude, 'longitude': location!.longitude} : null,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}