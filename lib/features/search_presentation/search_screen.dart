import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../data/models/charity.dart';
import '../../data/repositories/charity_repository.dart';
import '../../data/services/places_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // موقع افتراضي (مثلاً القاهرة)
  static const LatLng _initialPosition = LatLng(30.0444, 31.2357);

  GoogleMapController? _mapController;
  LatLng _currentPos = _initialPosition;
  bool _isLoadingLoc = true;
  String _selectedFilter = "All";

  final CharityRepository _charityRepo = CharityRepository();
  final PlacesService _placesService = PlacesService();
  
  List<Charity> _firestoreCharities = [];
  List<Charity> _nearbyCharities = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _determinePosition();
    await _loadFirestoreCharities();
    await _fetchNearbyCharities();
  }

  Future<void> _loadFirestoreCharities() async {
    try {
      final charities = await _charityRepo.getCharities();
      if (!mounted) return;
      setState(() {
        _firestoreCharities = charities;
        _updateMarkers();
      });
    } catch (e) {
      print("Error loading charities: $e");
    }
  }

  Future<void> _fetchNearbyCharities() async {
    try {
      final nearby = await _placesService.getNearbyCharities(_currentPos.latitude, _currentPos.longitude);
      if (!mounted) return;
      setState(() {
        _nearbyCharities = nearby;
        _updateMarkers();
      });
    } catch (e) {
      print("Error fetching nearby charities: $e");
    }
  }

  void _updateMarkers() {
    final List<Charity> allCharities = [..._firestoreCharities, ..._nearbyCharities];
    
    setState(() {
      _markers = allCharities.where((c) {
        if (_selectedFilter == "All") return true;
        if (c.category == "Nearby") return true; // Always show nearby search results
        return c.category == _selectedFilter;
      }).map((c) {
        return Marker(
          markerId: MarkerId(c.id),
          position: LatLng(c.latitude, c.longitude),
          infoWindow: InfoWindow(
            title: c.name,
            snippet: c.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            c.category == "Nearby" ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
        );
      }).toSet();

      // Add user location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('myLocation'),
          position: _currentPos,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _isLoadingLoc = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => _isLoadingLoc = false);
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPos = LatLng(position.latitude, position.longitude);
      _isLoadingLoc = false;
    });
    
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 14.0));
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = AppTheme.brown;

    return Scaffold(
      backgroundColor: themeColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- الجزء العلوي: العنوان ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Text(
                "Find causes that\nmatter to you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontFamily: 'Cairo',
                ),
              ),
            ),

            // --- الحاوية البيضاء الرئيسية ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceBeige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSearchBar(),

                      // --- الخريطة ---
                      Container(
                        height: 250,
                        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _currentPos,
                                  zoom: 13.0,
                                ),
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                  if (!_isLoadingLoc) {
                                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 14.0));
                                  }
                                },
                                markers: _markers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                            if (_isLoadingLoc)
                              Container(
                                color: Colors.white.withOpacity(0.6),
                                child: const Center(child: CircularProgressIndicator(color: AppTheme.brown)),
                              ),
                            Positioned(
                              bottom: 15,
                              right: 15,
                              child: FloatingActionButton.small(
                                onPressed: _determinePosition,
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.my_location, color: AppTheme.brown),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- الفلاتر (AI Matching) ---
                      _buildFilterRow(),

                      // باقي العناصر
                      const SizedBox(height: 15),
                      _buildSectionHeader("Recent Searches"),
                      _buildRecentChips(),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Suggested for you"),
                      _buildSuggestionList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search charities or locations",
          prefixIcon: const Icon(Icons.search, color: AppTheme.brown),
          suffixIcon: const Icon(Icons.tune, color: AppTheme.textGrey, size: 20),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    List<String> filters = ["All", "Food", "Clothes", "Medical"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: filters.map((f) {
          bool isSel = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(f, style: TextStyle(color: isSel ? Colors.white : AppTheme.textGrey, fontWeight: FontWeight.bold)),
              selected: isSel,
              selectedColor: AppTheme.brown,
              backgroundColor: Colors.white,
              onSelected: (val) {
                setState(() => _selectedFilter = f);
                _updateMarkers();
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChips() {
    List<String> recent = ["Education", "Food Bank", "Children"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: recent.map((item) {
          return GestureDetector(
            onTap: () => _onChipTapped(item),
            child: Chip(
              label: Text(item, style: const TextStyle(color: Color(0xFF2D3142), fontSize: 12)),
              backgroundColor: const Color(0xFFE3F2FD),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onChipTapped(String item) {
    final List<Charity> allCharities = [..._firestoreCharities, ..._nearbyCharities];
    if (allCharities.isEmpty) return;
    
    LatLng targetLocation;
    switch (item) {
      case "Education":
        targetLocation = LatLng(allCharities[0].latitude, allCharities[0].longitude);
        break;
      case "Food Bank":
        if (allCharities.length > 1) {
          targetLocation = LatLng(allCharities[1].latitude, allCharities[1].longitude);
        } else {
          targetLocation = _initialPosition;
        }
        break;
      case "Children":
        targetLocation = const LatLng(30.0333, 31.2333); // موقع آخر في القاهرة
        break;
      default:
        targetLocation = _initialPosition;
    }
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLocation, 15.0));
  }

  Widget _buildSuggestionList() {
    final List<Charity> allCharities = [..._firestoreCharities, ..._nearbyCharities];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allCharities.take(5).map((charity) {
        final distance = Geolocator.distanceBetween(
          _currentPos.latitude,
          _currentPos.longitude,
          charity.latitude,
          charity.longitude,
        ) / 1000; // تحويل لمتر إلى كم

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppTheme.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_outlined, color: AppTheme.brown),
            ),
            title: Text(charity.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            subtitle: Text("${charity.description.split(',').first} • ${distance.toStringAsFixed(1)} km away", style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
            onTap: () {
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(charity.latitude, charity.longitude), 15.0));
            },
          ),
        );
      }).toList(),
    );
  }
}