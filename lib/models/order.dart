import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'order.g.dart';

@HiveType(typeId: 1)
class Order {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final List<String> items; // 상품 id 리스트(간단화)
  @HiveField(2)
  final int total;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String storeId;
  @HiveField(6)
  final String userId;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.storeId,
    required this.userId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        items: List<String>.from(json['items'] ?? []),
        total: json['total'] as int,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        storeId: json['store_id'] as String,
        userId: json['user_id'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items,
        'total': total,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'store_id': storeId,
        'user_id': userId,
      };

  Order copyWith({
    String? id,
    List<String>? items,
    int? total,
    String? status,
    DateTime? createdAt,
    String? storeId,
    String? userId,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
    );
  }
}

class OrderListNotifier extends StateNotifier<List<Order>> {
  OrderListNotifier() : super([]);
  final _box = Hive.box<Order>('orders');

  void setOrders(List<Order> orders) {
    state = orders;
    _box.clear();
    for (final o in orders) {
      _box.put(o.id, o);
    }
  }

  void addOrder(Order order) {
    state = [...state, order];
    _box.put(order.id, order);
  }

  void updateOrder(Order order) {
    state = [
      for (final o in state)
        if (o.id == order.id) order else o
    ];
    _box.put(order.id, order);
  }

  void removeOrder(String id) {
    state = state.where((o) => o.id != id).toList();
    _box.delete(id);
  }

  void loadFromLocal() {
    final orders = _box.values.toList();
    state = orders;
  }
}

final orderListProvider = StateNotifierProvider<OrderListNotifier, List<Order>>(
  (ref) => OrderListNotifier(),
);
