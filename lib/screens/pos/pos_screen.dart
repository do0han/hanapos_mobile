import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product_grid.dart';
import '../../models/cart.dart';
import '../../services/supabase_service.dart';
import '../../screens/pos/order_history_screen.dart';
import '../../screens/pos/inventory_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Product> products = [];
  List<CartItem> cart = [];
  final supabaseService = SupabaseService();
  final storeId = 'b1e2c3d4-5678-90ab-cdef-1234567890ab';
  final cashierId = 'dda1e167-96a6-4d30-b9c5-e544b24cdf76';

  @override
  void initState() {
    super.initState();
    supabaseService.fetchProducts(storeId).then((list) {
      setState(() {
        products = list;
      });
    });
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
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ProductGrid(
              products: products,
              onProductTap: addToCart,
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
                      // 결제(더미) → Supabase에 주문 저장
                      await supabaseService.createOrder(
                        cart,
                        total,
                        storeId: storeId,
                        cashierId: cashierId,
                      );
                      setState(() {
                        cart.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주문이 완료되었습니다!')),
                      );
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
