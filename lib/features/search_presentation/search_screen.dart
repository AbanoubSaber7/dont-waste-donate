import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../data/models/charity.dart';
import '../../data/repositories/charity_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // موقع افتراضي (مثلاً القاهرة)
  static const LatLng _initialPosition = LatLng(30.0444, 31.2357);

  late MapController mapController;
  LatLng _currentPos = const LatLng(30.0444, 31.2357); // القاهرة كافتراضي
  bool _isLoadingLoc = true;
  String _selectedFilter = "All";

  final CharityRepository _charityRepo = CharityRepository();
  List<Charity> _allCharities = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _loadCharities();
    _determinePosition();
  }

  Future<void> _loadCharities() async {
    try {
      final charities = await _charityRepo.getCharities();
      if (!mounted) return;
      setState(() {
        _allCharities = charities;
        _updateMarkers();
      });
    } catch (e) {
      print("Error loading charities: $e");
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = _allCharities.where((c) {
        if (_selectedFilter == "All") return true;
        return c.category == _selectedFilter;
      }).map((c) {
        return Marker(
          point: LatLng(c.latitude, c.longitude),
          width: 80,
          height: 80,
          child: Tooltip(
            message: c.name,
            child: const Icon(Icons.location_on, color: Colors.red, size: 30),
          ),
        );
      }).toList();
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
    mapController.move(_currentPos, 14.0);
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
              child: const Text(
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
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: _currentPos,
                                  initialZoom: 13.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: "https://{s}.tile.jawg.io/jawg-sunny/{z}/{x}/{y}{r}.png?access-token={accessToken}",
                                    additionalOptions: const {
                                      'accessToken': 's9Z5tR6QVGGXtBFvFFbTaPGCAcwGrE6UJn3ZVPeezWpDpAd2IWJltsJCGAHLrkAB',
                                    },
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(markers: _getFilteredMarkers()),
                                ],
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

  List<Marker> _getFilteredMarkers() {
    return _markers;
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
    LatLng targetLocation;
    switch (item) {
      case "Education":
        targetLocation = _markers[0].point;
        break;
      case "Food Bank":
        targetLocation = _markers[1].point;
        break;
      case "Children":
        targetLocation = const LatLng(30.0333, 31.2333); // موقع آخر في القاهرة
        break;
      default:
        targetLocation = _initialPosition;
    }
    mapController.move(targetLocation, 15.0); // تحريك الخريطة إلى الموقع مع zoom
  }

  Widget _buildSuggestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _allCharities.take(3).map((charity) {
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
            subtitle: Text("Cairo • ${distance.toStringAsFixed(1)} km away", style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
            onTap: () {
              mapController.move(LatLng(charity.latitude, charity.longitude), 15.0);
            },
          ),
        );
      }).toList(),
    );
  }
}