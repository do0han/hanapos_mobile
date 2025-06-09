import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final _client = Supabase.instance.client;
  final String _table = 'products';

  Future<List<Product>> fetchProducts() async {
    final data = await _client.from(_table).select();
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> addProduct(Product product) async {
    final data = await _client
        .from(_table)
        .insert({
          'name': product.name,
          'price': product.price,
          'image_url': product.imageUrl,
          'category_id': product.categoryId,
          'description': product.description,
        })
        .select()
        .single();
    return Product.fromJson(data);
  }

  Future<Product> updateProduct(Product product) async {
    final data = await _client
        .from(_table)
        .update({
          'name': product.name,
          'price': product.price,
          'image_url': product.imageUrl,
          'category_id': product.categoryId,
          'description': product.description,
        })
        .eq('id', product.id)
        .select()
        .single();
    return Product.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
