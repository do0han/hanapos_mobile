import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductTile({required this.product, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (product.imageUrl.isNotEmpty)
              Image.network(product.imageUrl,
                  height: 60, width: 60, fit: BoxFit.cover),
            Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${product.price.toStringAsFixed(2)} ₱'),
          ],
        ),
      ),
    );
  }
}
