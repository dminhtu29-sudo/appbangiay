import 'shoe.dart';

class CartItem {
  final Shoe shoe;
  int quantity;
  String size;

  CartItem({required this.shoe, this.quantity = 1, required this.size});

  double get totalPrice => shoe.price * quantity;
}
