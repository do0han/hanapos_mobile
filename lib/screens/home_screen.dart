import 'package:flutter/material.dart';
import 'pos/pos_screen.dart';
// PosScreen import 필요시 추가
// import 'pos_screen.dart';

class HomeScreen extends StatelessWidget {
  final String jwtToken;
  const HomeScreen({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PosScreen(jwtToken: jwtToken),
              ),
            );
          },
          child: const Text('POS 주문/결제 화면'),
        ),
      ),
    );
  }
}
