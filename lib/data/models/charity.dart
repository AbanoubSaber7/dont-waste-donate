import 'package:cloud_firestore/cloud_firestore.dart';

class Charity {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., Food, Clothes
  final double latitude;
  final double longitude;
  final String imageUrl;

  Charity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.imageUrl = "",
  });

  factory Charity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    GeoPoint point = data['location'] as GeoPoint;
    return Charity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      latitude: point.latitude,
      longitude: point.longitude,
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
