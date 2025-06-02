import 'package:flutter/material.dart';
import '../../models/receipt.dart';

class ReceiptScreen extends StatelessWidget {
  final ReceiptData data;
  const ReceiptScreen({super.key, required this.data});

  String padRight(String s, int width) => s.padRight(width).substring(0, width);
  String padLeft(String s, int width) => s.padLeft(width).substring(0, width);

  @override
  Widget build(BuildContext context) {
    // 실제 프린터 출력은 고정폭 폰트 기준, 여기선 최대한 유사하게
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('영수증 미리보기')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text('[Service Invoice]',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text(data.companyName)),
                Center(child: Text(data.companyAddress)),
                Text('REG VAT TIN# ${data.vatTin}'),
                Text('S/N # ${data.serialNo}'),
                Text('Service Invoice # ${data.invoiceNo}'),
                const SizedBox(height: 8),
                Text('TABLE : ${data.table}'),
                const Divider(),
                Row(
                  children: [
                    padRight('ITEM', 16),
                    padLeft('QTY', 4),
                    padLeft('PRICE', 8),
                    padLeft('EXT', 8),
                  ].map((e) => Text(e)).toList(),
                ),
                ...data.items.map((item) => Row(
                      children: [
                        padRight(item.name, 16),
                        padLeft(item.qty.toString(), 4),
                        padLeft(item.price.toStringAsFixed(2), 8),
                        padLeft(item.ext.toStringAsFixed(2), 8),
                      ].map((e) => Text(e)).toList(),
                    )),
                const Divider(),
                Text(
                    'Total Amount      ${data.totalAmount.toStringAsFixed(2)}'),
                Text('VAT Amount        ${data.vatAmount.toStringAsFixed(2)}'),
                Text('Discount          ${data.discount.toStringAsFixed(2)}'),
                Text(
                    '${data.paymentMethod.padRight(16)}${data.paidAmount.toStringAsFixed(2)}'),
                if (data.paymentMethod == 'CARD' &&
                    (data.approvalNo?.isNotEmpty ?? false))
                  Text('승인번호: ${data.approvalNo}'),
                if (['TRANSFER', 'GCASH', 'PAYMAYA']
                        .contains(data.paymentMethod) &&
                    (data.transferNo?.isNotEmpty ?? false))
                  Text('송금번호: ${data.transferNo}'),
                Text('CHANGE            ${data.change.toStringAsFixed(2)}'),
                Text('PAYMENT METHOD     ${data.paymentMethod}'),
                const Divider(),
                Text('CUSTOMER : ${data.customerCount}'),
                Text('S/C PERSON: ${data.scPersonCount}'),
                if (data.scPwdId != null) Text('SC/PWD ID: ${data.scPwdId}'),
                if (data.scPwdName != null)
                  Text('SC/PWD NAME: ${data.scPwdName}'),
                const SizedBox(height: 8),
                Text('POS1 ${data.dateTime.toString()}'),
                Text(
                    'Cashier ${data.cashier} Transaction#${data.transactionNo}'),
                const SizedBox(height: 8),
                const Center(child: Text('This serves As Official Receipt..')),
                const Center(child: Text('Thank you..Come Again..')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
