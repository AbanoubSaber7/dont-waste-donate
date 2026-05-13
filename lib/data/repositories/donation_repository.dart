import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/donation.dart';

class DonationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _imgBBKey = "c21e6654329894f366637113303ab920";

  Future<String> uploadImage(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBKey'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['data']['url'];
      } else {
        throw Exception("Failed to upload image to ImgBB: ${response.statusCode}");
      }
    } catch (e) {
      print("ImgBB Upload Error: $e");
      rethrow;
    }
  }

  Future<void> addDonation(Donation donation) async {
    await _firestore.collection('donations').add(donation.toFirestore());
  }

  Stream<List<Donation>> getUserDonations(String userId) {
    return _firestore
        .collection('donations')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Donation.fromFirestore(doc)).toList());
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    await _firestore.collection('donations').doc(donationId).update({'status': status});
  }
}