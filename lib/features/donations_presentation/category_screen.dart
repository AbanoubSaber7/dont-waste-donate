import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../data/models/donation.dart';
import '../../data/providers/donation_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? _currentLocation;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب السماح بالوصول للموقع')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الوصول للموقع محظور، يرجى تفعيله من إعدادات التطبيق')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديد الموقع بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديد الموقع: $e')),
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = AppTheme.brown;
    final categoryImage = _getCategoryImage(widget.categoryName);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBeige,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDonateDialog(context),
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('تبرع الآن', style: TextStyle(color: Colors.white)),
      ),
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: themeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "${widget.categoryName} Causes",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  categoryImage.startsWith('assets/')
                      ? Image.asset(
                          categoryImage,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          categoryImage,
                          fit: BoxFit.cover,
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          themeColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Text(
                "Found 12 organizations for ${widget.categoryName}",
                style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildEnhancedOrgCard(context, index, themeColor);
                },
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryImage(String category) {
    const Map<String, String> categoryImages = {
      "Food": "assets/images/food.jpeg",
      "Health": "assets/images/health.jpeg",
      "Education": "assets/images/education.jpeg",
      "Orphans": "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&h=400&fit=crop",
      "Clothes": "assets/images/clothes.jpg",
      "Shelter": "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop",
    };
    return categoryImages[category] ?? categoryImages["Food"]!;
  }

  Widget _buildEnhancedOrgCard(BuildContext context, int index, Color themeColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // الانتقال لصفحة تفاصيل المؤسسة
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${widget.categoryName} Charity ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified, color: AppTheme.brown, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Helping families in Cairo since 2010",
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        const Text("4.9", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, color: AppTheme.brown.withOpacity(0.7), size: 16),
                        const SizedBox(width: 4),
                        const Text("2.5 km", style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تبرع في فئة ${widget.categoryName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف التبرع',
                hintText: 'مثال: ملابس مستعملة بحالة جيدة',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentLocation != null
                        ? 'الموقع: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
                        : 'لم يتم تحديد الموقع',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on),
                  tooltip: 'تحديد الموقع الحالي',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _submitDonation(context),
            child: const Text('تبرع'),
          ),
        ],
      ),
    );
  }

  void _submitDonation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final donation = Donation(
      id: '', // سيتم تعيينه من Firestore
      userId: user.uid,
      category: widget.categoryName,
      description: _descriptionController.text,
      location: _currentLocation,
      date: DateTime.now(),
      status: 'pending',
    );

    try {
      await ref.read(addDonationProvider(donation).future);
      _descriptionController.clear();
      setState(() {
        _currentLocation = null;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال التبرع بنجاح!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}