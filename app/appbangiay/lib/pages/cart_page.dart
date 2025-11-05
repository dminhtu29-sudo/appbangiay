import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/retro_theme.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String formatPrice(num price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}₫';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        elevation: 3,
        title: const Text(
          "Giỏ hàng của bạn",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                "🛍 Giỏ hàng trống rồi!",
                style: TextStyle(color: RetroTheme.textLight, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final key = cart.items.keys.toList()[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          cart.removeItem(key);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã xóa sản phẩm khỏi giỏ hàng"),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: RetroTheme.brownLight, width: 1),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  color: RetroTheme.textLight,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                color: RetroTheme.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Size: ${item.size}\nSố lượng: ${item.qty}\nGiá: ${formatPrice(item.price)}",
                                style: const TextStyle(
                                  color: RetroTheme.textLight,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatPrice(item.price * item.qty),
                                  style: const TextStyle(
                                    color: RetroTheme.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: RetroTheme.brownLight),
                                      onPressed: () {
                                        cart.removeSingle(key);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: RetroTheme.brown),
                                      onPressed: () {
                                        cart.addItem(
                                          key,
                                          item.name,
                                          item.price,
                                          item.image,
                                          item.size,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tổng tiền + nút thanh toán
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng:",
                            style: TextStyle(
                              fontSize: 16,
                              color: RetroTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatPrice(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: RetroTheme.brown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RetroTheme.brown,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.payment, color: Colors.white),
                          label: const Text(
                            "Tiến hành thanh toán",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
