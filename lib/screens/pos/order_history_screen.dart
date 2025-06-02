import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String? role;
  final String jwtToken;
  final String? storeId;
  final String? userId;
  const OrderHistoryScreen(
      {super.key,
      this.role,
      required this.jwtToken,
      this.storeId,
      this.userId});

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
    final orders = await SupabaseService.getOrdersRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      cashierId: (widget.role == 'cashier') ? widget.userId : null,
      role: widget.role,
    );
    setState(() {
      this.orders = orders;
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
          final userId = supabaseService.supabase.auth.currentUser?.id;
          final isMyOrder = order['cashier_id'] == userId;
          return ListTile(
            title: Text('주문금액: ${order['total']} ₱'),
            subtitle: Text(
                '결제방식: ${order['payment_method']} | 상태: ${order['status']}'),
            onTap: () async {
              final orderItems = await supabaseService.supabase
                  .from('order_items')
                  .select('quantity, price, subtotal, product:products(name)')
                  .eq('order_id', order['id']);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('주문 상세'),
                  content: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...orderItems.map<Widget>((item) => ListTile(
                              title: Text(item['product']['name'] ?? ''),
                              subtitle: Text(
                                  '수량: ${item['quantity']}  단가: ${item['price']}  소계: ${item['subtotal']}'),
                            )),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(order['created_at']?.toString().substring(0, 16) ?? ''),
                const SizedBox(width: 8),
                if (widget.role == 'owner' ||
                    widget.role == 'manager' ||
                    (widget.role == 'cashier' && isMyOrder)) ...[
                  ElevatedButton(
                    onPressed: () async {
                      await SupabaseService.cancelOrderRest(
                        token: widget.jwtToken,
                        orderId: order['id'].toString(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주문이 취소되었습니다!')),
                      );
                      await loadOrders();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                    child: const Text('주문 취소'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
