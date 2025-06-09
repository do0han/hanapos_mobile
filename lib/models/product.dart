import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double price;
  @HiveField(3)
  final String imageUrl;
  @HiveField(4)
  final String categoryId;
  @HiveField(5)
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        imageUrl: json['image_url'] ?? '',
        categoryId: json['category_id'] ?? '',
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'category_id': categoryId,
        'description': description,
      };
}
