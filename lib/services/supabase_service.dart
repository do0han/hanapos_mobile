import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/receipt.dart';
// ignore: uri_does_not_exist
import 'package:dio/dio.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts(String storeId) async {
    final res =
        await supabase.from('products').select().eq('store_id', storeId);
    print('products fetch result: $res');
    return (res as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<List<Product>> getProducts(String storeId) async {
    final res = await Supabase.instance.client
        .from('products')
        .select()
        .eq('store_id', storeId);
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

  // 주문 취소(환불) - order_items, orders 삭제 (트리거로 재고 복구)
  Future<void> cancelOrder(String orderId) async {
    await supabase.from('order_items').delete().eq('order_id', orderId);
    await supabase.from('orders').delete().eq('id', orderId);
  }

  // 유저의 role을 가져오는 메서드 (디버깅 추가)
  Future<String?> getUserRole(String userId) async {
    final res = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    final role = res != null ? res['role'] as String? : null;
    print('getUserRole: userId=$userId, role=$role, res=$res');
    return role;
  }

  Future<ReceiptData> generateReceiptData({
    required List<CartItem> cart,
    required double total,
    required String storeId,
    required String cashierId,
    required int transactionNo,
    required String paymentMethod,
    String? approvalNo,
    String? transferNo,
  }) async {
    // 실제 DB에서 회사/매장/고객 정보, 할인, 세금 등 fetch 필요. 여기선 mock
    return ReceiptData(
      companyName: 'COMPANY NAME',
      companyAddress: 'COMPANY ADDRESS',
      vatTin: '000-000-000-000',
      serialNo: 'XXXXXXXXXXXXXXX',
      invoiceNo: transactionNo.toString().padLeft(18, '0'),
      table: '1F_4',
      items: cart
          .map((e) => ReceiptItem(
                name: e.product.name,
                qty: e.quantity,
                price: e.product.price,
                ext: e.product.price * e.quantity,
              ))
          .toList(),
      totalAmount: total,
      vatAmount: (total / 1.12 * 0.12),
      discount: 0,
      paidAmount: total,
      change: 0,
      dateTime: DateTime.now(),
      customerCount: 2,
      scPersonCount: 1,
      scPwdId: '222',
      scPwdName: '',
      cashier: cashierId,
      transactionNo: transactionNo,
      paymentMethod: paymentMethod,
      approvalNo: approvalNo,
      transferNo: transferNo,
    );
  }

  // REST API로 상품 등록
  static Future<void> addProductRest({
    required String token,
    required String name,
    required int price,
    String? category,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/products';
    final body = {
      'name': name,
      'price': price,
      if (category != null && category.isNotEmpty) 'category': category,
    };
    await dio.post(url,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // REST API로 상품 수정
  static Future<void> updateProductRest({
    required String token,
    required int id,
    required String name,
    required int price,
    String? category,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/products';
    final body = {
      'id': id,
      'name': name,
      'price': price,
      if (category != null && category.isNotEmpty) 'category': category,
    };
    await dio.patch(url,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // REST API로 상품 삭제
  static Future<void> deleteProductRest({
    required String token,
    required int id,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/products';
    await dio.delete(url,
        data: {'id': id},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 주문 생성 (REST)
  static Future<void> createOrderRest({
    required String token,
    required String storeId,
    required String cashierId,
    required List<Map<String, dynamic>> items, // [{productId, qty, price}]
    required int total,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/orders'; // 실제 배포 주소로 교체
    await dio.post(
      url,
      data: {
        'storeId': storeId,
        'cashierId': cashierId,
        'items': items,
        'total': total,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 주문 리스트 조회 (REST)
  static Future<List<Map<String, dynamic>>> getOrdersRest({
    required String token,
    String? storeId,
    String? cashierId,
    String? role, // 'owner', 'manager', 'cashier'
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/orders';
    final params = {
      if (storeId != null) 'storeId': storeId,
      if (cashierId != null) 'cashierId': cashierId,
      if (role != null) 'role': role,
    };
    final res = await dio.get(url,
        queryParameters: params,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    final data = res.data['data'] as List;
    return List<Map<String, dynamic>>.from(data);
  }

  // 주문 취소 (REST)
  static Future<void> cancelOrderRest({
    required String token,
    required String orderId,
  }) async {
    final dio = Dio();
    final url = 'https://hanapos.yourdomain.com/api/orders/$orderId/cancel';
    await dio.post(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 재고 현황 조회 (REST)
  static Future<List<Map<String, dynamic>>> getInventoryRest({
    required String token,
    required String storeId,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/inventory';
    final res = await dio.get(url,
        queryParameters: {'storeId': storeId},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    final data = res.data['data'] as List;
    return List<Map<String, dynamic>>.from(data);
  }

  // 재고 조정 (REST)
  static Future<void> adjustInventoryRest({
    required String token,
    required String storeId,
    required String productId,
    required int delta,
    required String reason,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/inventory/adjust';
    await dio.post(url,
        data: {
          'storeId': storeId,
          'productId': productId,
          'delta': delta,
          'reason': reason,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 재고 이력 조회 (REST)
  static Future<List<Map<String, dynamic>>> getInventoryHistoryRest({
    required String token,
    required String storeId,
    required String productId,
  }) async {
    final dio = Dio();
    const url = 'https://hanapos.yourdomain.com/api/inventory/history';
    final res = await dio.get(url,
        queryParameters: {'storeId': storeId, 'productId': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    final data = res.data['data'] as List;
    return List<Map<String, dynamic>>.from(data);
  }

  // 매장 정보 조회
  static Future<Map<String, dynamic>> getStoreInfoRest({
    required String token,
    required String storeId,
  }) async {
    final dio = Dio();
    final url = 'https://hanapos.yourdomain.com/api/stores/$storeId';
    final res = await dio.get(url,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return res.data['data'] as Map<String, dynamic>;
  }

  // 매장 정보 수정
  static Future<void> updateStoreInfoRest({
    required String token,
    required String storeId,
    required Map<String, dynamic> update,
  }) async {
    final dio = Dio();
    final url = 'https://hanapos.yourdomain.com/api/stores/$storeId';
    await dio.patch(url,
        data: update,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 직원 목록 조회
  static Future<List<Map<String, dynamic>>> getStoreMembersRest({
    required String token,
    required String storeId,
  }) async {
    final dio = Dio();
    final url = 'https://hanapos.yourdomain.com/api/stores/$storeId/members';
    final res = await dio.get(url,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  // 직원 초대
  static Future<void> inviteMemberRest({
    required String token,
    required String storeId,
    required String email,
    required String role, // 'manager', 'cashier'
  }) async {
    final dio = Dio();
    final url = 'https://hanapos.yourdomain.com/api/stores/$storeId/invite';
    await dio.post(url,
        data: {'email': email, 'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 직원 권한 변경
  static Future<void> updateMemberRoleRest({
    required String token,
    required String storeId,
    required String memberId,
    required String role,
  }) async {
    final dio = Dio();
    final url =
        'https://hanapos.yourdomain.com/api/stores/$storeId/members/$memberId/role';
    await dio.patch(url,
        data: {'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 직원 삭제
  static Future<void> removeMemberRest({
    required String token,
    required String storeId,
    required String memberId,
  }) async {
    final dio = Dio();
    final url =
        'https://hanapos.yourdomain.com/api/stores/$storeId/members/$memberId';
    await dio.delete(url,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }
}
