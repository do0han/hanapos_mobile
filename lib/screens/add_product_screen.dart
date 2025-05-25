import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> fetchStoreIdForCurrentUser() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('profiles')
      .select('store_id')
      .eq('id', user.id)
      .single();

  return response['store_id'] as String?;
}

Future<void> signUpAndAssignStore(
    String email, String password, String storeId) async {
  final response = await Supabase.instance.client.auth.signUp(
    email: email,
    password: password,
  );
  final user = response.user;
  if (user != null) {
    // 회원가입 성공 → profiles에 store_id 할당
    await Supabase.instance.client.from('profiles').update({
      'store_id': storeId,
    }).eq('id', user.id);
    print('회원가입 및 store_id 할당 완료');
  } else {
    print('회원가입 실패');
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  String? storeId;

  @override
  void initState() {
    super.initState();
    fetchStoreId();
  }

  Future<void> fetchStoreId() async {
    storeId = await fetchStoreIdForCurrentUser();
    print('가져온 storeId: $storeId');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '상품명'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: storeId == null
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모든 필드를 입력하세요!')),
                        );
                        return;
                      }
                      try {
                        await Supabase.instance.client.from('products').insert({
                          'name': nameController.text,
                          'price': int.parse(priceController.text),
                          'category': categoryController.text,
                          'store_id': storeId,
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('상품 추가 성공!')),
                        );
                      } catch (e) {
                        print('상품 추가 실패: $e');
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('에러'),
                            content: Text('상품 추가 실패: $e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
              child: const Text('상품 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
