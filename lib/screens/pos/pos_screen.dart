import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product_grid.dart';
import '../../models/cart.dart';
import '../../services/supabase_service.dart';
import '../../screens/pos/order_history_screen.dart';
import '../../screens/pos/inventory_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_screen.dart';
import 'receipt_screen.dart';

class PosScreen extends StatefulWidget {
  final String jwtToken;
  const PosScreen({super.key, required this.jwtToken});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Product> products = [];
  List<CartItem> cart = [];
  final supabaseService = SupabaseService();
  String? storeId;
  String? cashierId;

  @override
  void initState() {
    super.initState();
    loadProfileAndProducts();
  }

  Future<void> loadProfileAndProducts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    cashierId = user.id;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('store_id')
        .eq('id', user.id)
        .maybeSingle();
    storeId = profile?['store_id'] as String?;
    if (storeId == null) return;
    products = await SupabaseService.getProducts(storeId!);
    setState(() {});
  }

  void addToCart(Product product) {
    setState(() {
      final idx = cart.indexWhere((item) => item.product.id == product.id);
      if (idx >= 0) {
        cart[idx].quantity += 1;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void removeFromCart(CartItem item) {
    setState(() {
      cart.remove(item);
    });
  }

  void changeQuantity(CartItem item, int delta) {
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) {
        cart.remove(item);
      }
    });
  }

  double get total => cart.fold(0, (sum, item) => sum + item.subtotal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderHistoryScreen(
                    role: null,
                    jwtToken: widget.jwtToken,
                    storeId: storeId,
                    userId: cashierId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InventoryScreen(
                    jwtToken: widget.jwtToken,
                    storeId: storeId ?? '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, idx) {
                final p = products[idx];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.price}원'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      addToCart(p);
                    },
                  ),
                );
              },
            ),
          ),
          // 장바구니 영역
          if (cart.isNotEmpty)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ...cart.map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.product.name),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => changeQuantity(item, -1),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => changeQuantity(item, 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeFromCart(item),
                              ),
                            ],
                          ),
                          Text('${item.subtotal.toStringAsFixed(2)} ₱'),
                        ],
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('합계',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${total.toStringAsFixed(2)} ₱',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (storeId == null || cashierId == null) return;
                      // 결제 화면으로 이동
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(total: total),
                        ),
                      );
                      if (result is Map && result['success'] == true) {
                        final paymentMethod =
                            result['paymentMethod'] as String? ?? 'CASH';
                        final approvalNo = result['approvalNo'] as String?;
                        final transferNo = result['transferNo'] as String?;
                        await supabaseService.createOrder(
                          cart,
                          total,
                          storeId: storeId!,
                          cashierId: cashierId!,
                        );
                        final receiptData =
                            await supabaseService.generateReceiptData(
                          cart: cart,
                          total: total,
                          storeId: storeId!,
                          cashierId: cashierId!,
                          transactionNo: DateTime.now().millisecondsSinceEpoch %
                              100000, // 임시
                          paymentMethod: paymentMethod,
                          approvalNo: approvalNo,
                          transferNo: transferNo,
                        );
                        setState(() {
                          cart.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문이 완료되었습니다!')),
                        );
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceiptScreen(data: receiptData),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('결제가 취소되었습니다.')),
                        );
                      }
                    },
                    child: const Text('결제하기'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
