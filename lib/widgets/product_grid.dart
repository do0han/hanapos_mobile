import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_tile.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onProductTap;

  const ProductGrid(
      {required this.products, required this.onProductTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, idx) => ProductTile(
        product: products[idx],
        onTap: () => onProductTap(products[idx]),
      ),
    );
  }
}
