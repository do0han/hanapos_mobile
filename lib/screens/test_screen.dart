import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테스트 전용 화면')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                // --- orders/product/inventory/order_items 등 테스트 버튼들 ---
                ElevatedButton(
                  onPressed: () async {
                    // 내 매장 주문 insert 테스트
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    final user = Supabase.instance.client.auth.currentUser;
                    try {
                      final response =
                          await Supabase.instance.client.from('orders').insert({
                        'total': 1000,
                        'payment_method': 'cash',
                        'status': 'paid',
                        'store_id': myStoreId,
                        'cashier_id': user?.id,
                      });
                      print('내 매장 insert 결과: $response');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('내 매장 insert 결과: $response')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('내 매장 주문 insert 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 남의 매장 주문 insert 테스트
                    const otherStoreId = 'b7e1c2d0-1234-4a5b-8cde-abcdef123456';
                    final user = Supabase.instance.client.auth.currentUser;
                    try {
                      final response =
                          await Supabase.instance.client.from('orders').insert({
                        'total': 1000,
                        'payment_method': 'cash',
                        'status': 'paid',
                        'store_id': otherStoreId,
                        'cashier_id': user?.id,
                      });
                      print('남의 매장 insert 결과: $response');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('남의 매장 insert 결과: $response')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('남의 매장 주문 insert 테스트'),
                ),
                // ... (이하 기존 홈화면에서 삭제한 모든 테스트 버튼 동일하게 추가) ...
                // 상품 insert, select, update, delete, orders select/update/delete, order_items, inventory 등
                // 필요하면 버튼별로 복붙해서 추가
              ],
            ),
          ),
        ),
      ),
    );
  }
}
