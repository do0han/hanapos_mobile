import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String paymentMethod = 'CASH';
  final List<String> methods = ['CASH', 'CARD', 'TRANSFER', 'GCASH', 'PAYMAYA'];
  final TextEditingController approvalController = TextEditingController();
  final TextEditingController transferController = TextEditingController();

  @override
  void dispose() {
    approvalController.dispose();
    transferController.dispose();
    super.dispose();
  }

  Widget _buildExtraField() {
    if (paymentMethod == 'CARD') {
      return TextField(
        controller: approvalController,
        decoration: const InputDecoration(
          labelText: '카드 승인번호',
        ),
      );
    } else if (['TRANSFER', 'GCASH', 'PAYMAYA'].contains(paymentMethod)) {
      return TextField(
        controller: transferController,
        decoration: const InputDecoration(
          labelText: '송금번호/거래번호',
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('결제 금액', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              Text('${widget.total.toStringAsFixed(2)} ₱',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              DropdownButton<String>(
                value: paymentMethod,
                items: methods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => paymentMethod = v!),
              ),
              const SizedBox(height: 16),
              _buildExtraField(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                  'success': true,
                  'paymentMethod': paymentMethod,
                  'approvalNo': approvalController.text,
                  'transferNo': transferController.text,
                }),
                child: const Text('결제 성공'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, {'success': false}),
                child: const Text('결제 취소'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
