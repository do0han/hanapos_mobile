import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class InventoryScreen extends StatefulWidget {
  final String jwtToken;
  final String storeId;
  const InventoryScreen(
      {super.key, required this.jwtToken, required this.storeId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final supabaseService = SupabaseService();
  List<Map<String, dynamic>> inventory = [];

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    final data = await SupabaseService.getInventoryRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
    );
    setState(() {
      inventory = data;
    });
  }

  Future<void> adjustQty(String productId, int delta) async {
    await SupabaseService.adjustInventoryRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      productId: productId,
      delta: delta,
      reason: delta > 0 ? '입고' : '출고',
    );
    await loadInventory();
  }

  Future<void> showHistory(String productId) async {
    final adjustments = await SupabaseService.getInventoryHistoryRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      productId: productId,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입출고 이력'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...adjustments.map<Widget>((adj) => ListTile(
                    title: Text('수량: \\${adj['quantity_change']}'),
                    subtitle: Text('사유: \\${adj['reason']}'),
                    trailing: Text(
                        adj['created_at']?.toString().substring(0, 16) ?? ''),
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
            onTap: () async {
              await showHistory(item['product_id']);
            },
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
                ElevatedButton(
                  onPressed: () async {
                    final controller = TextEditingController();
                    final result = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('입고 수량 입력'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '입고 수량'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              final qty = int.tryParse(controller.text);
                              Navigator.pop(context, qty);
                            },
                            child: const Text('입고'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result > 0) {
                      await adjustQty(item['product_id'], result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('입고 완료: +$result')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text('입고'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
