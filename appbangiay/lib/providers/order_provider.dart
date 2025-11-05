import 'package:flutter/material.dart';

/// 🧾 Mô hình đơn hàng
class OrderModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double total;
  final DateTime date;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.total,
    required this.date,
    required this.items,
  });
}

/// 👟 Mô tả từng sản phẩm trong đơn hàng
class OrderItem {
  final String id;
  final String name;
  final double price;
  final int qty;
  final String image;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.image,
  });
}

/// 📦 Provider quản lý danh sách đơn hàng
class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];

  /// Lấy danh sách đơn hàng hiện tại
  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// ➕ Thêm đơn hàng (khi đặt hàng cục bộ)
  void addOrder(OrderModel order) {
    _orders.insert(0, order); // thêm lên đầu
    notifyListeners();
  }

  /// 🔥 Thêm đơn hàng trực tiếp từ dữ liệu Firebase (Map)
  /// orderData chứa các trường: name, address, phone, total, date, items[]
  void addOrderFromFirebase(Map<String, dynamic> orderData,
      {String? idOptional}) {
    try {
      final id = idOptional ?? DateTime.now().toIso8601String();

      // Parse ngày
      final dateStr =
          orderData['date']?.toString() ?? DateTime.now().toIso8601String();
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();

      // Parse tổng tiền
      final total = (orderData['total'] is num)
          ? (orderData['total'] as num).toDouble()
          : double.tryParse(orderData['total']?.toString() ?? '0') ?? 0.0;

      // Parse danh sách sản phẩm
      final itemsRaw = orderData['items'] ?? [];
      final List<OrderItem> items = [];

      if (itemsRaw is List) {
        for (var it in itemsRaw) {
          if (it is Map) {
            final itemId =
                (it['id'] ?? DateTime.now().toIso8601String()).toString();
            final itemName = (it['name'] ?? '').toString();
            final itemPrice = (it['price'] is num)
                ? (it['price'] as num).toDouble()
                : double.tryParse(it['price']?.toString() ?? '0') ?? 0.0;
            final itemQty = (it['qty'] is int)
                ? it['qty'] as int
                : int.tryParse(it['qty']?.toString() ?? '1') ?? 1;
            final itemImage = (it['image'] ?? '').toString();

            items.add(OrderItem(
              id: itemId,
              name: itemName,
              price: itemPrice,
              qty: itemQty,
              image: itemImage,
            ));
          }
        }
      }

      // Tạo đối tượng OrderModel
      final order = OrderModel(
        id: id,
        name: (orderData['name'] ?? '').toString(),
        address: (orderData['address'] ?? '').toString(),
        phone: (orderData['phone'] ?? '').toString(),
        total: total,
        date: date,
        items: items,
      );

      addOrder(order);
    } catch (e) {
      debugPrint('❌ Lỗi khi thêm đơn hàng từ Firebase: $e');
    }
  }

  /// 🗑 Xóa đơn theo ID
  void removeOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  /// ♻️ Xóa toàn bộ danh sách đơn (chủ yếu để test)
  void clear() {
    _orders.clear();
    notifyListeners();
  }
}
