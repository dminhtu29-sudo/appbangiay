import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;
  final String customerName;
  final String phone;
  final String address;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Pending',
    required this.customerName,
    required this.phone,
    required this.address,
  });
}
