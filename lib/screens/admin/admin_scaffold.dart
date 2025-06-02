import 'package:flutter/material.dart';
import 'getting_started_screen.dart';
import 'dashboard_screen.dart';
import 'product_manage_screen.dart';
import 'order_manage_screen.dart';
import 'inventory_screen.dart';
import 'store_manage_screen.dart';
import 'customer_manage_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class AdminScaffold extends StatefulWidget {
  final String jwtToken;
  final String storeId;
  const AdminScaffold(
      {super.key, required this.jwtToken, required this.storeId});
  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int selectedIndex = 0;
  final menuTitles = [
    '대시보드',
    'Getting Started',
    '상품',
    '주문',
    '재고',
    '매장/직원',
    '고객',
    '리포트',
    '설정',
  ];
  final screens = [
    const DashboardScreen(),
    const GettingStartedScreen(),
    const ProductManageScreen(),
    const OrderManageScreen(),
    const AdminInventoryScreen(),
    const StoreManageScreen(),
    const CustomerManageScreen(),
    const ReportScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menuTitles[selectedIndex])),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('HANAPOS Admin')),
            ...List.generate(
                menuTitles.length,
                (i) => ListTile(
                      title: Text(menuTitles[i]),
                      selected: i == selectedIndex,
                      onTap: () {
                        setState(() => selectedIndex = i);
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
      ),
      body: screens[selectedIndex],
    );
  }
}
