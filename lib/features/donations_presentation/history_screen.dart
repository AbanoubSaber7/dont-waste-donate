import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/providers/donation_provider.dart';
import '../../data/models/donation.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('يجب تسجيل الدخول لعرض التبرعات'),
        ),
      );
    }

    final donationsAsync = ref.watch(userDonationsProvider(user.uid));

    return Scaffold(
      backgroundColor: AppTheme.brown,
      body: SafeArea(
        bottom: false, // عشان الحاوية البيضاء تنزل لآخر الشاشة
        child: Column(
          children: [
            // --- الجزء العلوي: العنوان والأيقونة ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Track all of your gifts\nin one place",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),

            // --- الجزء السفلي: قائمة التبرعات ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceBeige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  child: donationsAsync.when(
                    data: (donations) => ListView.builder(
                      padding: const EdgeInsets.fromLTRB(25, 35, 25, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: donations.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(donations[index]);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('خطأ: $error')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Donation donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.volunteer_activism, color: AppTheme.brown),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.category,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textBlack, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation.description,
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${donation.date.day}/${donation.date.month}/${donation.date.year}",
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: donation.status == 'pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    donation.status == 'pending' ? 'في الانتظار' : 'تم الاستلام',
                    style: TextStyle(
                      color: donation.status == 'pending' ? Colors.orange : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}