import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charity.dart';
import '../../utils/constants.dart';

class PlacesService {
  final String _apiKey = AppConstants.googleMapsApiKey;

  Future<List<Charity>> getNearbyCharities(double lat, double lng) async {
    if (_apiKey.isEmpty) {
      print("Google Maps API Key is missing. Please set GOOGLE_MAPS_API_KEY.");
      return [];
    }

    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000'
        '&type=establishment'
        '&keyword=charity'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((item) => Charity.fromGooglePlaces(item)).toList();
      } else {
        print("Places API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Places API Exception: $e");
      return [];
    }
  }
}
