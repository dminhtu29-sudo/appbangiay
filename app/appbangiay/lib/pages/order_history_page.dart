import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/retro_theme.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _db = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  String formatPrice(num price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}₫';
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Bạn cần đăng nhập để xem đơn hàng"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        elevation: 3,
        title: const Text(
          "Lịch sử đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _db.child('orders/${user!.uid}').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: RetroTheme.brown),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "Bạn chưa có đơn hàng nào 😢",
                style: TextStyle(color: RetroTheme.textLight, fontSize: 16),
              ),
            );
          }

          final rawData = snapshot.data!.snapshot.value;
          if (rawData is! Map) {
            return const Center(
              child: Text(
                "Không có dữ liệu đơn hàng",
                style: TextStyle(color: RetroTheme.textLight),
              ),
            );
          }

          final data = Map<String, dynamic>.from(rawData);
          final orders = data.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key)); // đơn mới nhất lên đầu

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderId = orders[index].key;
              final order = Map<String, dynamic>.from(orders[index].value);
              final date =
                  DateTime.tryParse(order['date'] ?? '') ?? DateTime.now();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPage(
                        orderId: orderId,
                        orderData: order,
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: RetroTheme.brownLight, width: 1),
                  ),
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long,
                        color: RetroTheme.brown, size: 32),
                    title: Text(
                      "Đơn hàng #$orderId",
                      style: const TextStyle(
                        color: RetroTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${date.day}/${date.month}/${date.year}\nTổng tiền: ${formatPrice(order['total'] ?? 0)}",
                      style: const TextStyle(
                        color: RetroTheme.textLight,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: RetroTheme.brown),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
