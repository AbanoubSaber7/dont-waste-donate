import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/charity.dart';

class CharityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Charity>> getCharities() async {
    final snapshot = await _firestore.collection('charities').get();
    return snapshot.docs.map((doc) => Charity.fromFirestore(doc)).toList();
  }

  Future<List<Charity>> getCharitiesByCategory(String category) async {
    final snapshot = await _firestore
        .collection('charities')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => Charity.fromFirestore(doc)).toList();
  }
}
