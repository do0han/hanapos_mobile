class ReceiptData {
  final String companyName;
  final String companyAddress;
  final String vatTin;
  final String serialNo;
  final String invoiceNo;
  final String table;
  final List<ReceiptItem> items;
  final double totalAmount;
  final double vatAmount;
  final double discount;
  final double paidAmount;
  final double change;
  final DateTime dateTime;
  final int customerCount;
  final int scPersonCount;
  final String? scPwdId;
  final String? scPwdName;
  final String cashier;
  final int transactionNo;
  final String paymentMethod;
  final String? approvalNo;
  final String? transferNo;
  // 기타 필요한 필드 추가 가능

  ReceiptData({
    required this.companyName,
    required this.companyAddress,
    required this.vatTin,
    required this.serialNo,
    required this.invoiceNo,
    required this.table,
    required this.items,
    required this.totalAmount,
    required this.vatAmount,
    required this.discount,
    required this.paidAmount,
    required this.change,
    required this.dateTime,
    required this.customerCount,
    required this.scPersonCount,
    this.scPwdId,
    this.scPwdName,
    required this.cashier,
    required this.transactionNo,
    required this.paymentMethod,
    this.approvalNo,
    this.transferNo,
  });
}

class ReceiptItem {
  final String name;
  final int qty;
  final double price;
  final double ext;
  ReceiptItem(
      {required this.name,
      required this.qty,
      required this.price,
      required this.ext});
}
