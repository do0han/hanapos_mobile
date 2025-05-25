import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final supabaseService = SupabaseService();
  List<Map<String, dynamic>> inventory = [];
  final storeId = 'b1e2c3d4-5678-90ab-cdef-1234567890ab';

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    final data = await supabaseService.fetchInventory(storeId);
    setState(() {
      inventory = data;
    });
  }

  Future<void> adjustQty(String productId, int delta) async {
    await supabaseService.adjustInventory(
        productId, delta, delta > 0 ? '입고' : '출고', storeId);
    await loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('재고 관리')),
      body: ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, idx) {
          final item = inventory[idx];
          final product = item['product'] ?? {};
          return ListTile(
            title: Text('${product['name']}'),
            subtitle: Text('재고: ${item['quantity']}개'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => adjustQty(item['product_id'], -1),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => adjustQty(item['product_id'], 1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
