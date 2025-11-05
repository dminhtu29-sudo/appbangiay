import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/retro_theme.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = Provider.of<CartProvider>(context, listen: false);

    String formatPrice(num price) {
      return '${price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          )}₫';
    }

    return Scaffold(
      backgroundColor: RetroTheme.beige,
      appBar: AppBar(
        backgroundColor: RetroTheme.brown,
        title: Text(
          product['name'] ?? "Chi tiết sản phẩm",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product['image'] ?? '',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 120,
                    color: RetroTheme.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tên sản phẩm
            Text(
              product['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: RetroTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),

            // Giá
            Text(
              formatPrice(product['price'] ?? 0),
              style: const TextStyle(
                color: RetroTheme.brown,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            Text(
              product['desc'] ?? '',
              style: const TextStyle(
                color: RetroTheme.textLight,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),

            // Chọn size giày
            const Text(
              "Chọn size giày:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: RetroTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['38', '39', '40', '41', '42', '43'].map((s) {
                final isSelected = selectedSize == s;
                return ChoiceChip(
                  label: Text(s),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : RetroTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  selected: isSelected,
                  selectedColor: RetroTheme.brown,
                  backgroundColor: Colors.white,
                  onSelected: (_) {
                    setState(() => selectedSize = s);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Nút thêm vào giỏ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RetroTheme.brown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: selectedSize == null
                    ? null
                    : () {
                        cart.addItem(
                          product['id'],
                          product['name'],
                          (product['price'] as num).toDouble(),
                          product['image'] ?? '',
                          selectedSize!,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: RetroTheme.brown,
                            content: Text(
                              '🛒 Đã thêm size $selectedSize vào giỏ hàng!',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
