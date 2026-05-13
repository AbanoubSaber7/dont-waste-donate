import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.brown,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // العنوان العلوي
          const Positioned(
            top: 10, left: 20, right: 20,
            child: Text(
              "How would you\nlike to pay?",
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

          // الحاوية البيضاء الرئيسية
          Positioned.fill(
            top: 130,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.surfaceBeige,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPaymentCard(Icons.credit_card, "Visa ending in 1234", Colors.blue[800]!, true),
                        _buildPaymentCard(Icons.account_balance_wallet, "MasterCard ending in 5678", Colors.red[700]!, false),
                        _buildAddMethod(context),

                        const SizedBox(height: 30),
                        _buildDonationSummary(),
                      ],
                    ),
                  ),

                  // زر FINISH النهائي
                  _buildFinishButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(IconData icon, String title, Color iconColor, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isSelected ? AppTheme.brown : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Cairo'),
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_off,
          color: isSelected ? AppTheme.brown : AppTheme.textGrey,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildAddMethod(BuildContext context) {
    return InkWell(
      onTap: () { /* فتح صفحة إضافة كارت جديد */ },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              "Add new payment method",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total Donation", style: TextStyle(color: AppTheme.textGrey, fontSize: 17, fontFamily: 'Cairo')),
          Text("\$50.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.brownDark)),
        ],
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: ElevatedButton(
        onPressed: () {
          // إتمام العملية بنجاح والعودة للرئيسية
          context.go('/');
        },
        child: const Text("FINISH"),
      ),
    );
  }
}