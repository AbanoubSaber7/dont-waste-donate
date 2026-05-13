import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/auth_providers.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final displayName = ref.watch(userNameProvider);

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
          child: Column(
            children: [
              const SizedBox(height: 20),
              // الهيدر يتغير بناءً على وجود المستخدم
              user == null ? _buildAuthPrompt(context) : _buildUserInfo(context, displayName),

              const SizedBox(height: 20),
              _buildImpactCard(),
              const SizedBox(height: 25),

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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSectionTitle("My Impact"),
                        _buildProfileItem(Icons.workspace_premium, "My Badges & Rewards", () {}),
                        _buildProfileItem(Icons.history, "Donation History", () => context.push('/history')),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(thickness: 0.8, color: Color(0xFFEEEEEE)),
                        ),

                        _buildSectionTitle("Personal Settings"),
                        _buildProfileItem(Icons.person_outline, "Account Information", () {}),

                        _buildSectionTitle("App Settings"),
                        _buildProfileItem(Icons.security, "Privacy & Security", () {}),

                        const SizedBox(height: 20),
                        // زر تسجيل الخروج يظهر فقط لو فيه مستخدم مسجل
                        if (user != null)
                          _buildProfileItem(Icons.logout, "Sign Out", () async {
                            await FirebaseAuth.instance.signOut();
                          }, isLogout: true),
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

  // الجزء الخاص بالمستخدم المسجل
  Widget _buildUserInfo(BuildContext context, String name) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white24,
            backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "Top Supporter since 2025",
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }

  // الجزء الخاص بسؤال المستخدم تسجيل الدخول (لو الاسم null)
  Widget _buildAuthPrompt(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.account_circle, size: 80, color: Colors.white24),
        const SizedBox(height: 15),
        const Text(
          "Join Our Mission",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.brown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("12", "Donations"),
          Container(width: 1, height: 30, color: Colors.white24),
          _statItem("45", "Lives Helped"),
          Container(width: 1, height: 30, color: Colors.white24),
          _statItem("Gold", "Badge"),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12, top: 18),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : AppTheme.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : AppTheme.brown),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: isLogout ? Colors.red : AppTheme.textBlack, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textGrey),
      ),
    );
  }
}