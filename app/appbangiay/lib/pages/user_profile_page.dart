import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'order_history_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = user?.email ?? "Không xác định";
    final userId = user?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0056D6),
        elevation: 0,
        title: const Text(
          "👤 Hồ sơ người dùng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage:
                    AssetImage('assets/avatar_placeholder.png'), // ảnh mặc định
              ),
              const SizedBox(height: 12),
              Text(
                userEmail,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "ID người dùng: $userId",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const Divider(height: 30),

              // 📜 Lịch sử đơn hàng
              ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: const Text(
                  "Lịch sử đơn hàng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                  );
                },
              ),
              const Divider(),

              // 🚪 Đăng xuất
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Đăng xuất",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
