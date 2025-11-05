import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/retro_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// 🧭 Lấy thông tin người dùng từ Firebase (users/{uid})
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _nameCtrl.text = data['name'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
      });
    }
  }

  /// 💳 Đặt hàng
  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Bạn cần đăng nhập trước khi đặt hàng')),
      );
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🛒 Giỏ hàng của bạn đang trống')),
      );
      return;
    }

    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❗Vui lòng điền đầy đủ thông tin giao hàng')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final db = FirebaseDatabase.instance.ref('orders/${user.uid}');
      final orderRef = db.push();

      final orderData = {
        'id': orderRef.key,
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'total': cart.totalAmount,
        'date': DateTime.now().toIso8601String(),
        'items': cart.items.values
            .map((e) => {
                  'id': e.id,
                  'name': e.name,
                  'price': e.price,
                  'qty': e.qty,
                  'image': e.image,
                })
            .toList(),
      };

      await orderRef.set(orderData);

      // 🧾 Cập nhật Provider
      Provider.of<OrderProvider>(context, listen: false)
          .addOrderFromFirebase(orderData, idOptional: orderRef.key);

      cart.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đặt hàng thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi đặt hàng: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        title: const Text('Xác nhận đơn hàng'),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                '🛒 Giỏ hàng trống, không thể thanh toán!',
                style: TextStyle(color: RetroTheme.textLight, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📦 Thông tin giao hàng",
                    style: TextStyle(
                      color: RetroTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên người nhận',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ giao hàng',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(thickness: 1.2, color: RetroTheme.brownLight),
                  const Text(
                    "🧾 Danh sách sản phẩm",
                    style: TextStyle(
                      color: RetroTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...cart.items.values.map((item) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                              color: RetroTheme.textDark,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${formatPrice(item.price)} x ${item.qty}",
                          style: const TextStyle(color: RetroTheme.textLight),
                        ),
                      ),
                    );
                  }),
                  const Divider(thickness: 1.2, color: RetroTheme.brownLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng:",
                        style: TextStyle(
                          color: RetroTheme.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatPrice(cart.totalAmount),
                        style: const TextStyle(
                          color: RetroTheme.brown,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                          _loading ? "Đang xử lý..." : "Xác nhận đặt hàng"),
                      onPressed: _loading ? null : _placeOrder,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
