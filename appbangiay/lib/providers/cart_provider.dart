import 'package:flutter/material.dart';

/// 🧺 Mô hình sản phẩm trong giỏ hàng
class CartItem {
  final String id;
  final String name;
  final double price;
  final int qty;
  final String image;
  final String size; // ✅ size giày đã chọn

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.image,
    required this.size,
  });
}

/// 🛒 Provider quản lý giỏ hàng
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {}; // key: productId-size

  bool _recentlyAdded = false;

  /// Danh sách sản phẩm trong giỏ
  Map<String, CartItem> get items => {..._items};

  /// Tổng số lượng sản phẩm
  int get totalQuantity {
    int total = 0;
    _items.forEach((_, item) => total += item.qty);
    return total;
  }

  /// Tổng tiền
  double get totalAmount {
    double total = 0.0;
    _items.forEach((_, item) {
      total += item.price * item.qty;
    });
    return total;
  }

  /// Hiệu ứng "nảy" khi thêm vào giỏ hàng
  bool get isRecentlyAdded => _recentlyAdded;
  void resetBounce() {
    _recentlyAdded = false;
    notifyListeners();
  }

  /// ➕ Thêm sản phẩm vào giỏ hàng (kèm size)
  void addItem(
      String productId, String name, double price, String image, String size) {
    final key = '$productId-$size'; // phân biệt theo size

    if (_items.containsKey(key)) {
      // nếu sản phẩm cùng size đã tồn tại -> tăng số lượng
      _items.update(
        key,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          qty: existing.qty + 1,
          image: existing.image,
          size: existing.size,
        ),
      );
    } else {
      // thêm mới
      _items.putIfAbsent(
        key,
        () => CartItem(
          id: DateTime.now().toString(),
          name: name,
          price: price,
          qty: 1,
          image: image,
          size: size,
        ),
      );
    }

    _recentlyAdded = true;
    notifyListeners();
  }

  /// ➖ Giảm số lượng 1 sản phẩm (hoặc xóa nếu qty = 1)
  void removeSingle(String key) {
    if (!_items.containsKey(key)) return;

    if (_items[key]!.qty > 1) {
      _items.update(
        key,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          qty: existing.qty - 1,
          image: existing.image,
          size: existing.size,
        ),
      );
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  /// 🗑 Xóa hoàn toàn 1 sản phẩm khỏi giỏ
  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  /// ♻️ Dọn sạch giỏ hàng
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
