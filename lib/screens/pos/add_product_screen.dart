import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? product; // null이면 등록, 있으면 수정
  const AddProductScreen({this.product, super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    _imageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageUrl = null; // 새로 선택하면 기존 url 무시
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: 이미지 업로드 로직 필요 (Supabase Storage 등)
    // 임시로 기존 url 또는 로컬 파일 path 사용
    final product = Product(
      id: widget.product?.id ?? '', // 신규면 빈값, 수정이면 기존 id
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      imageUrl: _imageUrl ?? (_imageFile?.path ?? ''),
      categoryId: widget.product?.categoryId ?? '',
      description: _descController.text,
    );
    if (widget.product == null) {
      await ref.read(productProvider.notifier).addProduct(product);
    } else {
      await ref.read(productProvider.notifier).updateProduct(product);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '상품 수정' : '상품 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 120)
                    : (_imageUrl != null && _imageUrl!.isNotEmpty
                        ? Image.network(_imageUrl!, height: 120)
                        : Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.add_a_photo, size: 48),
                          )),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? '수정' : '등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
