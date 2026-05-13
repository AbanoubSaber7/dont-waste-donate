import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../utils/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // قراءة اسم المستخدم ديناميكياً
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.brown, AppTheme.brownDark],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // تمرير context و userName للهيدر
              _buildAppBar(context, userName),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceBeige,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildImpactStats(ref),
                        const SizedBox(height: 10),
                        _buildSectionHeader(context, "Quick Categories"),
                        _buildCategories(context),
                        const SizedBox(height: 30),
                        _buildSectionHeader(context, "Featured Organizations"),
                        _buildFeaturedSlider(context),
                        const SizedBox(height: 30),
                        _buildSectionHeader(context, "Nearby You"),
                        _buildNearbyList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactStats(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("120", "Items Donated", Icons.volunteer_activism, Colors.green),
          _statItem("45", "Families Helped", Icons.people, Colors.blue),
          _statItem("85kg", "Waste Saved", Icons.eco, Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack)),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textGrey,
                fontFamily: 'Cairo')),
      ],
    );
  }

  // الهيدر المتحدث مع ربط الإشعارات والاسم
  Widget _buildAppBar(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, $name 👋", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const Text("Discover Causes", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
              // زر الإشعارات المربوط بالراوتر
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.push('/chat'),
                    tooltip: 'مساعد التبرع',
                    icon: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _searchBar(),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search organizations...",
          hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppTheme.brown),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
              fontFamily: 'Cairo',
            ),
          ),
          TextButton(
              onPressed: () => context.push('/search'),
              child: const Text("View all", style: TextStyle(color: AppTheme.brown, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    List<Map<String, dynamic>> cats = [
      {
        "name": "Food",
        "icon": Icons.fastfood,
        "color": Colors.orange,
        "image": "assets/images/food.jpeg"
      },
      {
        "name": "Clothes",
        "icon": Icons.shopping_bag,
        "color": Colors.pink,
        "image": "assets/images/clothes.jpg"
      },
      {
        "name": "Health",
        "icon": Icons.favorite,
        "color": Colors.red,
        "image": "assets/images/health.jpeg"
      },
      {
        "name": "Education",
        "icon": Icons.school,
        "color": Colors.blue,
        "image": "assets/images/education.jpeg"
      },
    ];
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => context.push('/select-category/${cats[index]['name']}'),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: cats[index]['image'].toString().startsWith('assets/')
                            ? AssetImage(cats[index]['image'].toString()) as ImageProvider
                            : NetworkImage(cats[index]['image'].toString()),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cats[index]['color'].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cats[index]['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textBlack, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSlider(BuildContext context) {
    final featured = [
      {
        "title": "Help Children in Need",
        "org": "Resala Charity",
        "img": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600&h=400&fit=crop"
      },
      {
        "title": "Feed a Family Today",
        "org": "Egyptian Food Bank",
        "img": "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&h=400&fit=crop"
      },
      {
        "title": "Clean Water Initiative",
        "org": "Misr El Kheir",
        "img": "https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=600&h=400&fit=crop"
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => context.push('/add-donation'),
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(featured[index]['img']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(featured[index]['title']!,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    Text(featured[index]['org']!, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildOrgCard(context, "جمعية رسالة", "مدينة نصر - 2 كم", Icons.volunteer_activism),
          _buildOrgCard(context, "بنك الطعام المصري", "التجمع الخامس - 5 كم", Icons.flatware),
        ],
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, String title, String sub, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/add-donation'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppTheme.brown),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(sub, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
          ),
        ),
      ),
    );
  }

}