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
                ElevatedButton(
                  onPressed: () async {
                    // 내 매장 store_id로 상품 insert
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    try {
                      final insertRes = await Supabase.instance.client
                          .from('products')
                          .insert({
                        'name': '테스트상품',
                        'price': 1000,
                        'store_id': myStoreId,
                      }).select();
                      print('상품 insert 결과: $insertRes');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('상품 insert 결과: $insertRes')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('상품 insert 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 내 매장 상품 select
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    try {
                      final products = await Supabase.instance.client
                          .from('products')
                          .select()
                          .eq('store_id', myStoreId);
                      print('상품 select 결과: $products');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('상품 select 결과: $products')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('상품 select 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 상품 update (id는 실제 insert된 상품 id로 교체)
                    const productId = 'bf9ff7a0-8c38-4d4c-bd0a-25417b72d68c';
                    try {
                      final updateRes = await Supabase.instance.client
                          .from('products')
                          .update({'price': 2000})
                          .eq('id', productId)
                          .select();
                      print('상품 update 결과: $updateRes');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('상품 update 결과: $updateRes')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('상품 update 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 상품 delete (id는 실제 insert된 상품 id로 교체)
                    const productId = 'bf9ff7a0-8c38-4d4c-bd0a-25417b72d68c';
                    try {
                      final deleteRes = await Supabase.instance.client
                          .from('products')
                          .delete()
                          .eq('id', productId)
                          .select();
                      print('상품 delete 결과: $deleteRes');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('상품 delete 결과: $deleteRes')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('상품 delete 테스트'),
                ),
                // --- orders 테스트 버튼 ---
                ElevatedButton(
                  onPressed: () async {
                    // orders insert (내 매장)
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    final user = Supabase.instance.client.auth.currentUser;
                    try {
                      final res =
                          await Supabase.instance.client.from('orders').insert({
                        'total': 5000,
                        'payment_method': 'cash',
                        'status': 'paid',
                        'store_id': myStoreId,
                        'cashier_id': user?.id,
                      }).select();
                      print('orders insert 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('orders insert 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('orders insert 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // orders select (내 매장)
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    try {
                      final res = await Supabase.instance.client
                          .from('orders')
                          .select()
                          .eq('store_id', myStoreId);
                      print('orders select 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('orders select 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('orders select 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // orders update (id는 실제 insert된 주문 id로 교체)
                    const orderId = '여기에_주문_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('orders')
                          .update({'status': 'cancelled'})
                          .eq('id', orderId)
                          .select();
                      print('orders update 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('orders update 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('orders update 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // orders delete (id는 실제 insert된 주문 id로 교체)
                    const orderId = '여기에_주문_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('orders')
                          .delete()
                          .eq('id', orderId)
                          .select();
                      print('orders delete 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('orders delete 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('orders delete 테스트'),
                ),
                // --- order_items 테스트 버튼 ---
                ElevatedButton(
                  onPressed: () async {
                    // order_items insert (실제 주문/상품 id로 교체)
                    const orderId = '여기에_주문_id_복사';
                    const productId = '여기에_상품_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('order_items')
                          .insert({
                        'order_id': orderId,
                        'product_id': productId,
                        'quantity': 2,
                        'price': 1000,
                        'subtotal': 2000,
                      }).select();
                      print('order_items insert 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('order_items insert 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('order_items insert 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // order_items select (실제 주문 id로 교체)
                    const orderId = '여기에_주문_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('order_items')
                          .select()
                          .eq('order_id', orderId);
                      print('order_items select 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('order_items select 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('order_items select 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // order_items update (id는 실제 order_items id로 교체)
                    const orderItemId = '여기에_order_items_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('order_items')
                          .update({'quantity': 3})
                          .eq('id', orderItemId)
                          .select();
                      print('order_items update 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('order_items update 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('order_items update 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // order_items delete (id는 실제 order_items id로 교체)
                    const orderItemId = '여기에_order_items_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('order_items')
                          .delete()
                          .eq('id', orderItemId)
                          .select();
                      print('order_items delete 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('order_items delete 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('order_items delete 테스트'),
                ),
                // --- inventory 테스트 버튼 ---
                ElevatedButton(
                  onPressed: () async {
                    // inventory insert (실제 상품/매장 id로 교체)
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    const productId = '여기에_상품_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('inventory')
                          .insert({
                        'product_id': productId,
                        'quantity': 10,
                        'store_id': myStoreId,
                      }).select();
                      print('inventory insert 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('inventory insert 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('inventory insert 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // inventory select (내 매장)
                    const myStoreId = '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114';
                    try {
                      final res = await Supabase.instance.client
                          .from('inventory')
                          .select()
                          .eq('store_id', myStoreId);
                      print('inventory select 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('inventory select 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('inventory select 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // inventory update (id는 실제 inventory id로 교체)
                    const inventoryId = '여기에_inventory_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('inventory')
                          .update({'quantity': 20})
                          .eq('id', inventoryId)
                          .select();
                      print('inventory update 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('inventory update 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('inventory update 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // inventory delete (id는 실제 inventory id로 교체)
                    const inventoryId = '여기에_inventory_id_복사';
                    try {
                      final res = await Supabase.instance.client
                          .from('inventory')
                          .delete()
                          .eq('id', inventoryId)
                          .select();
                      print('inventory delete 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('inventory delete 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('inventory delete 테스트'),
                ),
                // --- Supabase 인증/프로필 테스트 버튼 ---
                ElevatedButton(
                  onPressed: () async {
                    // 회원가입
                    try {
                      final res = await Supabase.instance.client.auth.signUp(
                        email: 'testuser1@example.com',
                        password: 'testpassword',
                      );
                      print('회원가입 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('회원가입 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 로그인
                    try {
                      final res = await Supabase.instance.client.auth
                          .signInWithPassword(
                        email: 'testuser1@example.com',
                        password: 'testpassword',
                      );
                      print('로그인 결과: $res');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 결과: $res')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('로그인 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 프로필 조회
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인 필요')),
                      );
                      return;
                    }
                    try {
                      final profile = await Supabase.instance.client
                          .from('profiles')
                          .select()
                          .eq('id', user.id)
                          .single();
                      print('프로필: $profile');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('프로필: ${profile.toString()}')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('프로필 조회 테스트'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 프로필 수정 (store_id, role)
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인 필요')),
                      );
                      return;
                    }
                    try {
                      final updateRes = await Supabase.instance.client
                          .from('profiles')
                          .update({
                        'store_id': '7cc4ce9a-0925-4a66-8bd4-16b60a2c3114',
                        'role': 'manager',
                      }).eq('id', user.id);
                      print('프로필 수정 결과: $updateRes');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('프로필 수정 결과: ${updateRes.toString()}')),
                      );
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러: $e')),
                      );
                    }
                  },
                  child: const Text('프로필 수정 테스트'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
