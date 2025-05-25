import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/cart.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts(String storeId) async {
    final res =
        await supabase.from('products').select().eq('store_id', storeId);
    print('products fetch result: $res');
    return (res as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<void> createOrder(List<CartItem> cart, double total,
      {required String storeId, required String cashierId}) async {
    try {
      final orderRes = await supabase
          .from('orders')
          .insert({
            'total': total,
            'payment_method': 'cash',
            'status': 'paid',
            'store_id': storeId,
            'cashier_id': cashierId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orderId = orderRes['id'];

      // order_items 테이블에 각 상품 추가
      final items = cart
          .map((item) => {
                'order_id': orderId,
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'subtotal': item.subtotal,
              })
          .toList();

      await supabase.from('order_items').insert(items);
    } catch (e) {
      print('createOrder error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final res = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // 재고 현황 조회
  Future<List<Map<String, dynamic>>> fetchInventory(String storeId) async {
    final res = await supabase
        .from('inventory')
        .select(
            'id, product_id, quantity, updated_at, product:products(name, price)')
        .eq('store_id', storeId);
    print('fetchInventory result: $res');
    return List<Map<String, dynamic>>.from(res);
  }

  // 재고 조정(입고/출고)
  Future<void> adjustInventory(
      String productId, int delta, String reason, String storeId) async {
    // 1. inventory 테이블 수량 업데이트
    final invRes = await supabase
        .from('inventory')
        .select()
        .eq('product_id', productId)
        .eq('store_id', storeId)
        .maybeSingle();

    int newQty = (invRes?['quantity'] ?? 0) + delta;

    await supabase
        .from('inventory')
        .update({
          'quantity': newQty,
          'updated_at': DateTime.now().toIso8601String()
        })
        .eq('product_id', productId)
        .eq('store_id', storeId);

    // 2. stock_adjustments 테이블에 이력 기록
    await supabase.from('stock_adjustments').insert({
      'product_id': productId,
      'quantity_change': delta,
      'reason': reason,
      'store_id': storeId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
