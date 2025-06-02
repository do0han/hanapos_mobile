import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductScreen extends StatefulWidget {
  final String storeId;
  const AddProductScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 추가')),
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
                try {
                  final insertRes = await Supabase.instance.client
                      .from('products')
                      .insert({
                        'name': nameController.text,
                        'price': int.parse(priceController.text),
                        'category': categoryController.text,
                        'store_id': widget.storeId,
                      })
                      .select()
                      .single();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('상품 추가 성공!')),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('상품 추가 실패: \\${e.toString()}')),
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
