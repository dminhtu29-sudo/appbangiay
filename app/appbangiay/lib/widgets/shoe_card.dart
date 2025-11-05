import 'package:flutter/material.dart';
import '../models/shoe.dart';

class ShoeCard extends StatelessWidget {
  final Shoe shoe;
  const ShoeCard({super.key, required this.shoe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(child: Image.network(shoe.imageUrl, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  shoe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${shoe.price.toStringAsFixed(0)} ₫",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
