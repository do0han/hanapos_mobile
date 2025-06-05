import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

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
  final String storeId;
  final Product? product;
  final String jwtToken;
  const AddProductScreen(
      {super.key, required this.storeId, this.product, required this.jwtToken});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text = widget.product!.price.toString();
      // category 필드가 있으면 세팅, 없으면 무시
      try {
        final cat = (widget.product as dynamic).category;
        if (cat != null) {
          categoryController.text = cat;
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '상품 수정' : '상품 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              onPressed: () async {
                final name = nameController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                final category = categoryController.text.trim();
                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('상품명/가격을 입력하세요')),
                  );
                  return;
                }
                if (isEdit) {
                  // Supabase 직접 쿼리로 수정
                  await Supabase.instance.client.from('products').update({
                    'name': name,
                    'price': price,
                    if (category.isNotEmpty) 'category': category,
                  }).eq('id', widget.product!.id);
                } else {
                  // Supabase 직접 쿼리로 추가
                  await Supabase.instance.client.from('products').insert({
                    'name': name,
                    'price': price,
                    'store_id': widget.storeId,
                    if (category.isNotEmpty) 'category': category,
                  });
                }
                Navigator.pop(context, true);
              },
              child: Text(isEdit ? '수정 완료' : '상품 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
