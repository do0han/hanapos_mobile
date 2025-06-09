import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String storeId;
  final String jwtToken;
  const ProductListScreen(
      {super.key, required this.storeId, required this.jwtToken});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _search = '';
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _sort = '이름순';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productProvider.notifier).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    final products = state.products
        .where((p) => _search.isEmpty || p.name.contains(_search))
        .where((p) =>
            _selectedCategory == null || p.categoryId == _selectedCategory)
        .toList()
      ..sort((a, b) => _sort == '이름순'
          ? a.name.compareTo(b.name)
          : a.price.compareTo(b.price));

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 리스트'),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '상품명 검색',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      setState(() => _search = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sort,
                  items: const [
                    DropdownMenuItem(value: '이름순', child: Text('이름순')),
                    DropdownMenuItem(value: '가격순', child: Text('가격순')),
                  ],
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ],
            ),
          ),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (state.error != null)
            Expanded(child: Center(child: Text('에러: ${state.error}'))),
          if (!state.isLoading && state.error == null)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => notifier.fetchProducts(),
                child: products.isEmpty
                    ? const Center(child: Text('상품 없음'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth > 600;
                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 3 : 1,
                              childAspectRatio: isTablet ? 1.8 : 3.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, idx) {
                              final p = products[idx];
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: p,
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(p.name),
                                  subtitle: Text('${p.price}원'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (p.description != null)
                                        Text(p.description!),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddProductScreen(
                                                storeId: widget.storeId,
                                                product: p,
                                                jwtToken: widget.jwtToken,
                                              ),
                                            ),
                                          );
                                          notifier.fetchProducts();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          await notifier.deleteProduct(p.id);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('상품 삭제 완료!')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(
                storeId: widget.storeId,
                jwtToken: widget.jwtToken,
              ),
            ),
          );
          notifier.fetchProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
