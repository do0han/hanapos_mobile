import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_list_screen.dart';
import 'pos/pos_screen.dart';
import 'pos/inventory_screen.dart';
import 'pos/order_history_screen.dart';
import 'test_screen.dart';
import 'store_manage_screen.dart';
// ...필요한 import...

class HomeScreen extends StatefulWidget {
  final String? role;
  final String? jwtToken;
  const HomeScreen({super.key, this.role, this.jwtToken});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? role;
  String? storeId;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('role, store_id')
        .eq('id', user.id)
        .maybeSingle();
    setState(() {
      role = profile?['role'] as String?;
      storeId = profile?['store_id'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen role: $role, storeId: $storeId');
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내 역할: ${role ?? "없음"}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (role == 'owner') ...[
                  // 오너만: 매장 관리, 직원 관리 등
                ],
                if (role == 'manager' || role == 'owner') ...[
                  // 매니저/오너: 상품 추가, 주문 취소 등
                ],
                if (role == 'cashier') ...[
                  // 캐셔: 주문 생성, 내 주문 취소 등
                ],
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    if (role == 'owner' || role == 'manager') ...[
                      ElevatedButton(
                        onPressed: () async {
                          if (storeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('매장 정보 없음')),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductScreen(
                                  storeId: storeId!,
                                  jwtToken: widget.jwtToken!),
                            ),
                          );
                        },
                        child: const Text('상품 추가'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (storeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('매장 정보 없음')),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreManageScreen(
                                jwtToken: widget.jwtToken!,
                                storeId: storeId!,
                              ),
                            ),
                          );
                        },
                        child: const Text('매장/직원 관리'),
                      ),
                    ],
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
                        if (storeId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매장 정보 없음')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListScreen(
                                storeId: storeId!, jwtToken: widget.jwtToken!),
                          ),
                        );
                      },
                      child: const Text('상품 리스트 화면'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PosScreen(jwtToken: widget.jwtToken!),
                          ),
                        );
                      },
                      child: const Text('POS 주문/결제 화면'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (storeId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매장 정보 없음')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryScreen(
                              jwtToken: widget.jwtToken!,
                              storeId: storeId!,
                            ),
                          ),
                        );
                      },
                      child: const Text('재고 관리 화면'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderHistoryScreen(
                              role: role,
                              jwtToken: widget.jwtToken!,
                              storeId: storeId,
                              userId:
                                  Supabase.instance.client.auth.currentUser?.id,
                            ),
                          ),
                        );
                      },
                      child: const Text('주문 내역 화면'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TestScreen(),
                          ),
                        );
                      },
                      child: const Text('테스트 전용 화면'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
