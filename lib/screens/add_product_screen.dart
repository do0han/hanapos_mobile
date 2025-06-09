import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'dart:io';

class AddProductScreen extends ConsumerStatefulWidget {
  final String storeId;
  final Product? product;
  final String jwtToken;
  const AddProductScreen(
      {super.key, required this.storeId, this.product, required this.jwtToken});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final descController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text = widget.product!.price.toString();
      categoryController.text = widget.product!.categoryId;
      descController.text = widget.product!.description ?? '';
      _imageUrl = widget.product!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final notifier = ref.read(productProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '상품 수정' : '상품 추가')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile != null
                  ? Image.file(_imageFile!, height: 140, fit: BoxFit.cover)
                  : (_imageUrl != null && _imageUrl!.isNotEmpty)
                      ? Image.network(_imageUrl!,
                          height: 140, fit: BoxFit.cover)
                      : Container(
                          height: 140,
                          color: Colors.grey[200],
                          child: const Center(child: Text('이미지 선택')),
                        ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '상품명'),
              validator: (v) => v == null || v.trim().isEmpty ? '필수 입력' : null,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '필수 입력';
                final n = num.tryParse(v);
                if (n == null || n <= 0) return '유효한 가격 입력';
                return null;
              },
            ),
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: '설명'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);
                  try {
                    // TODO: 이미지 업로드(Supabase Storage 연동 필요, 현재는 기존 url 유지)
                    final product = Product(
                      id: widget.product?.id ?? '',
                      name: nameController.text.trim(),
                      price: double.parse(priceController.text.trim()),
                      imageUrl: _imageUrl ?? '',
                      categoryId: categoryController.text.trim(),
                      description: descController.text.trim(),
                    );
                    if (isEdit) {
                      await notifier.updateProduct(product);
                    } else {
                      await notifier.addProduct(product);
                    }
                    if (mounted) Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('에러: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: Text(isEdit ? '수정 완료' : '상품 추가'),
              ),
          ],
        ),
      ),
    );
  }
}
