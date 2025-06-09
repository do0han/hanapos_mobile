import 'package:flutter_test/flutter_test.dart';
import 'package:hanapos_mobile/services/product_service.dart';
import 'package:hanapos_mobile/models/product.dart';

void main() {
  final service = ProductService();

  test('상품 목록 불러오기', () async {
    final products = await service.fetchProducts();
    expect(products, isA<List<Product>>());
    // 실제 데이터가 있다면 아래 라인도 활성화
    // expect(products.isNotEmpty, true);
  });
}
