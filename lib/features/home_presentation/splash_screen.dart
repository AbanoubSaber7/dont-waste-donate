import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال للصفحة الرئيسية بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/'); // بيروح للـ HomeScreen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الصورة كخلفية كاملة
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // طبقة شفافة لضمان وضوح النص
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF5F5DC).withOpacity(0.7), // نفس لون البيج بتاع الخلفية القديمة بس شفاف
            ),
          ),
          // المحتوى في المنتصف
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't Waste Donate",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF8B4513),
                    fontFamily: 'Cairo',
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.white, offset: Offset(0, 0))
                    ]
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Color(0xFF8B4513)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}