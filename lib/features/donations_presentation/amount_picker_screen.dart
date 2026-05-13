import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class AmountPickerScreen extends StatelessWidget {
  const AmountPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color themeColor = AppTheme.brown;

    return Scaffold(
      backgroundColor: themeColor,
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
              "How much would\nyou like to give?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),

          // الحاوية البيضاء
          Positioned.fill(
            top: 120,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFBFBFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.1, // لجعل الأزرار شبه مربعة ومنسقة
                      children: [
                        _buildAmountBtn(context, "\$10", false),
                        _buildAmountBtn(context, "\$25", false),
                        _buildAmountBtn(context, "\$50", true), // مثال على خيار محدد
                        _buildAmountBtn(context, "\$100", false),
                        _buildAmountBtn(context, "\$250", false),
                        _buildAmountBtn(context, "Other", false),
                      ],
                    ),
                  ),

                  // زر الاستمرار السفلي
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => context.push('/select-category/Donation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBtn(BuildContext context, String label, bool isSelected) {
    final Color themeColor = AppTheme.brown;

    return InkWell(
      onTap: () {
        // هنا يمكن إضافة منطق لتخزين القيمة المختارة
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : themeColor,
          ),
        ),
      ),
    );
  }
}