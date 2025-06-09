import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl, height: 120)
                  : const Icon(Icons.image, size: 120),
            ),
            const SizedBox(height: 16),
            Text('상품명: [200b][200b]${product.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('가격: ₩${product.price}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (product.description != null && product.description!.isNotEmpty)
              const Text('설명: [200b]{product.description}',
                  style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
