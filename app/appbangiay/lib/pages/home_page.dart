import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/cart_provider.dart';
import '../theme/retro_theme.dart';
import '../auth/login_page.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dbRef = FirebaseDatabase.instance.ref('products');
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  String formatPrice(num price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        elevation: 3,
        title: Row(
          children: const [
            Icon(Icons.storefront, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              "Sneaker Store",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // 👤 Hồ sơ cá nhân
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          // 🛒 Giỏ hàng
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: cart.isRecentlyAdded ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    onEnd: () => cart.resetBounce(),
                    child: IconButton(
                      icon:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      tooltip: 'Giỏ hàng',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                    ),
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 10,
                      top: 12,
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // 📜 Lịch sử đơn hàng
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Lịch sử đơn hàng',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
          ),
          // 🚪 Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // Nội dung chính
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon:
                    const Icon(Icons.search, color: RetroTheme.textLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: RetroTheme.brownLight),
                ),
              ),
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: RetroTheme.brown),
                  );
                }

                final event = snapshot.data;
                if (event == null || event.snapshot.value == null) {
                  return const Center(
                    child: Text(
                      "Chưa có sản phẩm nào 😢",
                      style: TextStyle(color: RetroTheme.textLight),
                    ),
                  );
                }

                final data =
                    Map<String, dynamic>.from(event.snapshot.value as Map);
                final entries = data.entries.toList();

                // Lọc sản phẩm theo tìm kiếm
                final filteredEntries = entries.where((e) {
                  final name = (e.value['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredEntries.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không tìm thấy sản phẩm nào!",
                      style: TextStyle(color: RetroTheme.textLight),
                    ),
                  );
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  itemCount: filteredEntries.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final key = filteredEntries[index].key;
                    final product =
                        Map<String, dynamic>.from(filteredEntries[index].value);

                    final name = product['name'] ?? '';
                    final price = product['price'] ?? 0;
                    final desc = product['desc'] ?? '';
                    final image = product['image'] ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: RetroTheme.brownLight, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh sản phẩm
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: Image.network(
                              image,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: RetroTheme.textLight,
                              ),
                            ),
                          ),
                          // Thông tin sản phẩm
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: RetroTheme.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatPrice(price),
                                  style: const TextStyle(
                                    color: RetroTheme.brown,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: const TextStyle(
                                    color: RetroTheme.textLight,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: RetroTheme.brown,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailPage(
                                                product: {
                                                  'id': key,
                                                  'name': name,
                                                  'price': price,
                                                  'desc': desc,
                                                  'image': image,
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("Chi tiết"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
