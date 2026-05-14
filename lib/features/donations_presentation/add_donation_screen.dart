import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../data/providers/ai_service_provider.dart';

import '../../utils/donation_providers.dart';

// --- الأسئلة الديناميكية بناءً على المتطلبات ---
final isTornProvider = StateProvider<bool>((ref) => false);
final isCleanProvider = StateProvider<bool>((ref) => true);
final usageTimeProvider = StateProvider<String>((ref) => "Less than 1 year");

final isFreshProvider = StateProvider<bool>((ref) => true);
final isCookedProvider = StateProvider<bool>((ref) => false);
final foodExpiryProvider = StateProvider<String>((ref) => "Valid");

class AddDonationScreen extends ConsumerWidget {
  const AddDonationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color themeColor = AppTheme.brown;
    final donationImage = ref.watch(donationImageProvider);
    final isAnalyzing = ref.watch(isAnalyzingProvider);

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
              _buildSimpleAppBar(context),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Do more\ngood.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceBeige,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "New Donation",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
                        ),
                        const Text(
                          "AI Analysis & Categorization",
                          style: TextStyle(fontSize: 14, color: AppTheme.textGrey, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 30),

                        // 1. قسم التقاط الصورة والتحليل الذكي
                        _buildPhotoSection(ref, donationImage, isAnalyzing),

                        // 2. نتيجة قرار الـ AI (تظهر بعد انتهاء التحليل)
                        if (donationImage != null && !isAnalyzing) ...[
                          const SizedBox(height: 25),
                          _buildAIDecisionCard(ref),
                        ],

                        // 3. تفاصيل إضافية تظهر فقط لو مقبول
                        if (donationImage != null && !isAnalyzing && (ref.watch(aiAcceptedProvider) == true)) ...[
                          const SizedBox(height: 25),
                          _buildCategorySection(ref),
                          const SizedBox(height: 25),
                          _buildDynamicQuestions(ref),
                        ],

                        const SizedBox(height: 30),
                        _buildDescription(),
                        const SizedBox(height: 40),

                        // 4. الأزرار
                        _buildActionButtons(context, ref, themeColor, donationImage, isAnalyzing),
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

  // --- المكونات الفرعية (Widgets) ---

  Widget _buildSimpleAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }


  Widget _buildPhotoSection(WidgetRef ref, File? image, bool isAnalyzing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Item Photo",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: isAnalyzing ? null : () => _pickImage(ref),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppTheme.brown.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isAnalyzing
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.brown),
                  SizedBox(height: 12),
                  Text("AI is analyzing item condition...", style: TextStyle(color: AppTheme.brown, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            )
                : (image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.file(image, fit: BoxFit.cover),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_enhance_outlined, size: 50, color: AppTheme.brown),
                SizedBox(height: 10),
                Text("Capture item for AI analysis", style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicQuestions(WidgetRef ref) {
    final category = ref.watch(donationCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz_outlined, color: AppTheme.brown, size: 22),
            const SizedBox(width: 8),
            Text(
              "Verify $category Details",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (category == "Clothes") _buildClothesQuestions(ref),
        if (category == "Food") _buildFoodQuestions(ref),
        if (category != "Clothes" && category != "Food")
          const Text("Please provide details in the next step.", style: TextStyle(color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildClothesQuestions(WidgetRef ref) {
    final isTorn = ref.watch(isTornProvider);
    final isClean = ref.watch(isCleanProvider);

    return Column(
      children: [
        _buildSwitchTile("Is it torn or damaged?", isTorn, (val) => ref.read(isTornProvider.notifier).state = val),
        _buildSwitchTile("Is it clean and ready?", isClean, (val) => ref.read(isCleanProvider.notifier).state = val),
        const SizedBox(height: 10),
        _buildDropdown("Usage Period", ref.watch(usageTimeProvider), ["Less than 1 year", "1-3 years", "More than 3 years"],
            (val) => ref.read(usageTimeProvider.notifier).state = val!),
      ],
    );
  }

  Widget _buildFoodQuestions(WidgetRef ref) {
    final isFresh = ref.watch(isFreshProvider);
    final isCooked = ref.watch(isCookedProvider);

    return Column(
      children: [
        _buildSwitchTile("Is it fresh and safe?", isFresh, (val) => ref.read(isFreshProvider.notifier).state = val),
        _buildSwitchTile("Is it a cooked meal?", isCooked, (val) => ref.read(isCookedProvider.notifier).state = val),
        const SizedBox(height: 10),
        _buildDropdown("Expiry Status", ref.watch(foodExpiryProvider), ["Valid", "Expires Soon", "Expired"],
            (val) => ref.read(foodExpiryProvider.notifier).state = val!),
      ],
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.brown,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (pickedFile != null) {
      // إعادة تعيين القرار السابق
      ref.read(aiAcceptedProvider.notifier).state = null;
      ref.read(aiReasonProvider.notifier).state = "";
      ref.read(isAnalyzingProvider.notifier).state = true;

      final file = File(pickedFile.path);
      ref.read(donationImageProvider.notifier).state = file;

      // تحليل الصورة بالـ AI لتحديد القرار (مؤقتاً، لا تُرفع الصورة)
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.analyzeDonationItem(file);

      ref.read(donationCategoryProvider.notifier).state = result['category']!;
      ref.read(itemConditionProvider.notifier).state = result['condition']!;
      ref.read(aiAcceptedProvider.notifier).state = result['accepted'] == 'true';
      ref.read(aiReasonProvider.notifier).state = result['reason'] ?? '';

      ref.read(isAnalyzingProvider.notifier).state = false;
    }
  }

  /// بطاقة قرار الـ AI: مقبول ✅ أو مرفوض ❌
  Widget _buildAIDecisionCard(WidgetRef ref) {
    final accepted = ref.watch(aiAcceptedProvider);
    final reason = ref.watch(aiReasonProvider);
    final condition = ref.watch(itemConditionProvider);

    if (accepted == null) return const SizedBox.shrink();

    final isAccepted = accepted == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAccepted
            ? const Color(0xFFE8F5E9)  // أخضر فاتح
            : const Color(0xFFFFEBEE),  // أحمر فاتح
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted ? const Color(0xFF43A047) : const Color(0xFFE53935),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isAccepted ? const Color(0xFF43A047) : const Color(0xFFE53935),
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isAccepted ? "✅ Donation Accepted" : "❌ Donation Rejected",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isAccepted ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Condition: $condition",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textBlack),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            style: TextStyle(
              fontSize: 13,
              color: isAccepted ? const Color(0xFF388E3C) : const Color(0xFFB71C1C),
              height: 1.4,
            ),
          ),
          if (!isAccepted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.refresh, size: 16, color: AppTheme.brown),
                const SizedBox(width: 6),
                Text(
                  "Try again with a different item.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }

  /// الأزرار: إما CONTINUE (لو مقبول) أو زر إعادة التصوير (لو مرفوض)
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Color color,
      File? image, bool isAnalyzing) {
    final accepted = ref.watch(aiAcceptedProvider);
    final selectedCategory = ref.watch(donationCategoryProvider);

    // لو لسه ما صوّرش أو لسه بيحلل
    if (image == null || isAnalyzing || accepted == null) {
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: null,
          child: const Text(
            "CONTINUE",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      );
    }

    if (accepted == false) {
      // مرفوض - زر إعادة المحاولة فقط
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text(
            "RETAKE PHOTO",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.brown,
            side: const BorderSide(color: AppTheme.brown, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () => _pickImage(ref),
        ),
      );
    }

    // مقبول - زر الاستمرار
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          // بعد الموافقة، ننتقل مباشرة للخريطة للبحث عن أقرب جمعية
          context.go('/search');
        },
        child: const Text(
          "CONTINUE",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Our AI system ensures that your donation is categorized correctly to reach those in need faster.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
    );
  }

  Widget _buildCategorySection(WidgetRef ref) {
    final selectedCategory = ref.watch(donationCategoryProvider);
    const categories = ["Food", "Clothes", "Health", "Education", "Shelter"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.category, color: AppTheme.brown, size: 20),
            SizedBox(width: 8),
            Text(
              "Select Donation Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: AppTheme.brown,
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                ref.read(donationCategoryProvider.notifier).state = category;
              },
            );
          }).toList(),
        ),
      ],
    );
  }


  String _calculateStatus(WidgetRef ref) {
    final category = ref.read(donationCategoryProvider);
    if (category == "Clothes") {
      final isTorn = ref.read(isTornProvider);
      final isClean = ref.read(isCleanProvider);
      if (isTorn) return "damaged";
      if (isClean) return "good condition";
      return "needs cleaning";
    } else if (category == "Food") {
      final isFresh = ref.read(isFreshProvider);
      final expiry = ref.read(foodExpiryProvider);
      if (expiry == "Expired" || !isFresh) return "not safe";
      if (expiry == "Expires Soon") return "use fast";
      return "fresh";
    }
    return "good condition";
  }
}