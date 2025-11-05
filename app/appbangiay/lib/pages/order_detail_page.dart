import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  final Map<dynamic, dynamic> orderData;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  String formatPrice(num price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}₫';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Chuyển LinkedMap -> Map<String, dynamic> an toàn
    final safeOrderData = orderData.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    // ✅ Chuyển danh sách sản phẩm sang List<Map<String, dynamic>>
    final items = (safeOrderData['items'] is List)
        ? List<Map<String, dynamic>>.from(
            (safeOrderData['items'] as List).map((item) {
              if (item is Map) {
                return item.map(
                  (key, value) => MapEntry(key.toString(), value),
                );
              }
              return <String, dynamic>{};
            }),
          )
        : <Map<String, dynamic>>[];

    final total = (safeOrderData['total'] is num)
        ? (safeOrderData['total'] as num).toDouble()
        : 0.0;
    final date =
        DateTime.tryParse(safeOrderData['date'] ?? '') ?? DateTime.now();

    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Đơn hàng #$orderId",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Ngày đặt hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ngày đặt hàng:",
                  style: TextStyle(
                    color: RetroTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                    color: RetroTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 🔹 Địa chỉ giao hàng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Địa chỉ:",
                  style: TextStyle(
                    color: RetroTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    safeOrderData['address'] ?? 'Chưa có địa chỉ',
                    style: const TextStyle(
                      color: RetroTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            const Text(
              "Danh sách sản phẩm:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: RetroTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Danh sách sản phẩm
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: RetroTheme.brownLight, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            color: RetroTheme.textLight),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              color: RetroTheme.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Size: ${item['size'] ?? '-'}",
                            style: const TextStyle(
                              color: RetroTheme.textLight,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "SL: ${item['qty']} × ${formatPrice(item['price'] ?? 0)}",
                            style: const TextStyle(
                              color: RetroTheme.textLight,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatPrice(
                          ((item['price'] ?? 0) * (item['qty'] ?? 1)) as num),
                      style: const TextStyle(
                        color: RetroTheme.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 30),

            // 🔹 Tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng cộng:",
                  style: TextStyle(
                    color: RetroTheme.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formatPrice(total),
                  style: const TextStyle(
                    color: RetroTheme.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🔹 Trạng thái đơn hàng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RetroTheme.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: RetroTheme.brownLight),
              ),
              child: Center(
                child: Text(
                  safeOrderData['status'] ?? "Trạng thái: Đang xử lý 🕓",
                  style: const TextStyle(
                    color: RetroTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
