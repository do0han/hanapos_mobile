import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String storeId;
  final String jwtToken;
  const ProductListScreen(
      {required this.storeId, required this.jwtToken, super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // REST API 방식
    _productsFuture = SupabaseService.getProductsRest(
      token: widget.jwtToken,
      // search: '', limit: 20, offset: 0 등 필요시 추가
    );
    // 기존 Supabase 직접 접근 방식(비권장)
    // _productsFuture = SupabaseService.getProducts(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 리스트')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('상품 없음'));
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, idx) {
              final p = products[idx];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${p.price}원'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.description != null) Text(p.description!),
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
                        setState(() {
                          _productsFuture = SupabaseService.getProductsRest(
                            token: widget.jwtToken,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await SupabaseService.deleteProductRest(
                          token: widget.jwtToken,
                          id: int.parse(p.id.toString()),
                        );
                        setState(() {
                          _productsFuture = SupabaseService.getProductsRest(
                            token: widget.jwtToken,
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('상품 삭제 완료!')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(
                  storeId: widget.storeId, jwtToken: widget.jwtToken),
            ),
          );
          if (result == true) {
            setState(() {
              _productsFuture = SupabaseService.getProductsRest(
                token: widget.jwtToken,
              );
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
