import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ...필요한 import...

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductScreen()),
                );
              },
              child: const Text('상품 추가'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  print('현재 로그인된 유저 ID: \\${user.id}');
                  print('이메일: \\${user.email}');
                } else {
                  print('로그인된 유저 없음');
                }
              },
              child: const Text('유저 정보 확인'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
