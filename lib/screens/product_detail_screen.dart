import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 (여러 장 지원 시 PageView, 단일이면 Image.network)
            if (product.imageUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(product.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${product.price}원',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (product.categoryId.isNotEmpty)
              Text('카테고리: ${product.categoryId}',
                  style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!,
                  style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                  onPressed: () {
                    // TODO: 수정 화면으로 이동
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('삭제'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // TODO: 삭제 로직
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
