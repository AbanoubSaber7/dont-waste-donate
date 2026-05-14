import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../data/models/donation.dart';
import '../../data/repositories/donation_repository.dart';

final donationRepoProvider = Provider((ref) => DonationRepository());

class DonationDetailsScreen extends ConsumerStatefulWidget {
  final String category; // مثلاً 'Food' أو 'Clothes'
  final String status;
  const DonationDetailsScreen({super.key, required this.category, required this.status});

  @override
  ConsumerState<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends ConsumerState<DonationDetailsScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tell us more about your donation",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 20),
            _buildAISummary(),
            const SizedBox(height: 30),
            
            const Text(
              "Matched Organizations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
            ),
            const Text("Based on AI category and proximity", style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            const SizedBox(height: 15),
            _buildMatchedOrgs(),
            const SizedBox(height: 30),

            // لو التبرع "أكل" نظهر تاريخ الصلاحية
            if (widget.category == "Food") ...[
              _buildInputField("Food Type (e.g. Canned, Fresh)", Icons.fastfood),
              const SizedBox(height: 20),
              _buildInputField("Expiry Date", Icons.date_range),
            ],

            // لو التبرع "لبس" نظهر المقاس والنوع
            if (widget.category == "Clothes") ...[
              _buildInputField("Size (S, M, L, XL)", Icons.straighten),
              const SizedBox(height: 20),
              _buildInputField("Gender (Men, Women, Kids)", Icons.people),
            ],

            const SizedBox(height: 20),
            _buildInputField("Quantity / Number of items", Icons.format_list_numbered, controller: _quantityController),
            const SizedBox(height: 20),
            _buildInputField("Additional Notes", Icons.note_add, maxLines: 3, controller: _notesController),

            const SizedBox(height: 40),

            // زرار الإنهاء
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDonation,
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SUBMIT DONATION"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDonation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // الصورة تُستخدم فقط للتحليل في الشاشة السابقة ولا تُخزَّن
      final donation = Donation(
        id: "", // Firestore generates ID
        userId: user.uid,
        category: widget.category,
        description: "${_notesController.text} (Quantity: ${_quantityController.text})",
        date: DateTime.now(),
        status: "pending",
        imageUrl: null, // لا نرفع الصورة
      );

      await ref.read(donationRepoProvider).addDonation(donation);
      
      if (!mounted) return;
      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildAISummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.brown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brown.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.brown, size: 20),
              const SizedBox(width: 8),
              Text(
                "AI Analysis Result: ${widget.status.toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getSuggestionText(),
            style: const TextStyle(color: AppTheme.textBlack, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getSuggestionText() {
    switch (widget.status) {
      case "good condition":
      case "fresh":
        return "Suggesting: High-priority charities (e.g., Resala, Food Bank).";
      case "needs cleaning":
        return "Suggesting: Local collection points for preparation.";
      case "damaged":
      case "not safe":
        return "Suggesting: Material recycling centers or disposal.";
      case "use fast":
        return "Suggesting: Nearby families in immediate need.";
      default:
        return "Suggesting: Local community centers.";
    }
  }

  Widget _buildInputField(String hint, IconData icon, {int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.brown),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.brown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.brown, size: 80),
              ),
              const SizedBox(height: 25),
              const Text(
                "رائع!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 15),
              const Text(
                "تم إرسال تبرعك بنجاح. شكراً لك!",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textGrey, fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text("Back to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onOrgSelected(String orgName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Matched with $orgName"), backgroundColor: AppTheme.brown),
    );
  }

  Widget _buildMatchedOrgs() {
    final List<Map<String, String>> orgs = _getFilteredOrgs();
    return Column(
      children: orgs.map((org) => Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.brown.withOpacity(0.1))),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppTheme.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business, color: AppTheme.brown),
          ),
          title: Text(org['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          subtitle: Text("${org['distance']} • ${org['type']}", style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.brown),
          onTap: () => _onOrgSelected(org['name']!),
        ),
      )).toList(),
    );
  }

  List<Map<String, String>> _getFilteredOrgs() {
    if (widget.category == "Food") {
      return [
        {"name": "Egyptian Food Bank", "distance": "1.2 km", "type": "Food Specialist"},
        {"name": "Resala - Food Section", "distance": "2.5 km", "type": "General Charity"},
      ];
    } else if (widget.category == "Clothes") {
      return [
        {"name": "Orman Association", "distance": "3.1 km", "type": "Clothes & Furniture"},
        {"name": "Refuge Egypt", "distance": "4.5 km", "type": "Clothing Aid"},
      ];
    }
    return [
      {"name": "Local Community Center", "distance": "0.8 km", "type": "General Support"},
    ];
  }
}