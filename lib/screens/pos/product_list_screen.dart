import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _search = '';
  String _sort = 'name';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    List<Product> products = state.products;
    // 검색
    if (_search.isNotEmpty) {
      products = products.where((p) => p.name.contains(_search)).toList();
    }
    // 정렬
    products.sort((a, b) {
      switch (_sort) {
        case 'price':
          return a.price.compareTo(b.price);
        case 'name':
        default:
          return a.name.compareTo(b.name);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.fetchProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '상품명 검색',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: _sort,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('이름순')),
                  DropdownMenuItem(value: 'price', child: Text('가격순')),
                ],
                onChanged: (v) => setState(() => _sort = v!),
              ),
            ],
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => notifier.fetchProducts(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, idx) {
                        return _ProductCard(product: products[idx]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, height: 80)
                : const Icon(Icons.image, size: 80),
            Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('₩${product.price}'),
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(product: product),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // 삭제 로직 예정
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
