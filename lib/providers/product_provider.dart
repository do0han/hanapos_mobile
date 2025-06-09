import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  ProductState({
    required this.products,
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _service;
  static const _boxName = 'productsBox';
  ProductNotifier(this._service) : super(ProductState(products: []));

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null, isOffline: false);
    try {
      final products = await _service.fetchProducts();
      state = state.copyWith(
          products: products, isLoading: false, isOffline: false);
      // 캐싱
      final box = await Hive.openBox<Product>(_boxName);
      await box.clear();
      await box.addAll(products);
    } catch (e) {
      // 네트워크 실패 시 Hive에서 로드
      final box = await Hive.openBox<Product>(_boxName);
      final cached = box.values.toList();
      state = state.copyWith(
          products: cached,
          isLoading: false,
          error: '오프라인 데이터',
          isOffline: true);
    }
  }

  Future<void> addProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newProduct = await _service.addProduct(product);
      final updated = [...state.products, newProduct];
      state = state.copyWith(products: updated, isLoading: false);
      final box = await Hive.openBox<Product>(_boxName);
      await box.add(newProduct);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.updateProduct(product);
      final idx = state.products.indexWhere((p) => p.id == updated.id);
      if (idx != -1) {
        final updatedList = [...state.products];
        updatedList[idx] = updated;
        state = state.copyWith(products: updatedList, isLoading: false);
        final box = await Hive.openBox<Product>(_boxName);
        final key = box.keys.elementAt(idx);
        await box.put(key, updated);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deleteProduct(id);
      final updated = state.products.where((p) => p.id != id).toList();
      state = state.copyWith(products: updated, isLoading: false);
      final box = await Hive.openBox<Product>(_boxName);
      final idx = box.values.toList().indexWhere((p) => p.id == id);
      if (idx != -1) await box.deleteAt(idx);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ProductService()),
);
