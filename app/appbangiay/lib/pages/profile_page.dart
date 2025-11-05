import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/retro_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _addressCtrl.text = data['address'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    await ref.set({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'email': user!.email,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Đã lưu thông tin cá nhân")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: RetroTheme.brown)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ của tôi"),
        backgroundColor: RetroTheme.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: RetroTheme.brownLight,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Tên hiển thị"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: "Địa chỉ"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Lưu thông tin"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
