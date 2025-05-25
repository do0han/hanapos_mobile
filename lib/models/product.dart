class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        imageUrl: json['image_url'] ?? '',
        categoryId: json['category_id'] ?? '',
      );
}
