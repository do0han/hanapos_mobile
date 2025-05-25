import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final supabaseService = SupabaseService();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final data = await supabaseService.fetchOrders();
    setState(() {
      orders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주문 내역')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, idx) {
          final order = orders[idx];
          return ListTile(
            title: Text('주문금액: ${order['total']} ₱'),
            subtitle: Text(
                '결제방식: ${order['payment_method']} | 상태: ${order['status']}'),
            trailing:
                Text(order['created_at']?.toString().substring(0, 16) ?? ''),
          );
        },
      ),
    );
  }
}
