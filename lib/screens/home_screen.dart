import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ...필요한 import...

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductScreen()),
                );
              },
              child: const Text('상품 추가'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  print('현재 로그인된 유저 ID: \\${user.id}');
                  print('이메일: \\${user.email}');
                } else {
                  print('로그인된 유저 없음');
                }
              },
              child: const Text('유저 정보 확인'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('로그아웃'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 내 매장 store_id로 테스트 (예시)
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
                // 남의 매장 store_id로 테스트 (예시)
                const otherStoreId =
                    'b7e1c2d0-1234-4a5b-8cde-abcdef123456'; // 실제 남의 매장 store_id로 교체
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
          ],
        ),
      ),
    );
  }
}
