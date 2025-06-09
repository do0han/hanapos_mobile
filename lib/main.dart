import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  await Supabase.initialize(
    url: 'https://fjyuajkqcetfpglbfxsx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqeXVhamtxY2V0ZnBnbGJmeHN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0ODA0MDIsImV4cCI6MjA2MzA1NjQwMn0.7MVC3rTSGBozUP3Hqdeqsx0wvVW1BVBMfSTUGt0xGwM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HANAPOS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

Future<void> signUp(String email, String password) async {
  try {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      print('회원가입 성공: ${response.user!.id}');
    } else {
      print('회원가입 실패: 알 수 없는 이유');
    }
  } catch (e) {
    print('회원가입 에러: $e');
  }
}

Future<void> fetchProducts(String storeId) async {
  final response = await Supabase.instance.client
      .from('products')
      .select()
      .eq('store_id', storeId);
  print('products: $response');
}

Future<void> fetchInventory(String storeId) async {
  final response = await Supabase.instance.client
      .from('inventory')
      .select()
      .eq('store_id', storeId);
  print('inventory: $response');
}

Future<void> createOrder({
  required String storeId,
  required String cashierId,
  required num total,
}) async {
  final orderInsert = await Supabase.instance.client.from('orders').insert({
    'total': total,
    'payment_method': 'cash',
    'status': 'paid',
    'store_id': storeId,
    'cashier_id': cashierId,
  }).select();
  print('orderInsert: $orderInsert');
}

Future<void> updateProfileStoreAndRole({
  required String storeId,
  required String role, // 'admin', 'user', 'manager' 중 하나
}) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    print('로그인된 유저가 없습니다.');
    return;
  }

  final response = await Supabase.instance.client.from('profiles').update({
    'store_id': storeId,
    'role': role,
  }).eq('id', user.id);

  print('profiles 업데이트 결과: $response');
}

// 상품 리스트 불러오기 (매장별)
Future<List<Map<String, dynamic>>> fetchProductsByStore(String storeId) async {
  final response = await Supabase.instance.client
      .from('products')
      .select()
      .eq('store_id', storeId);

  // 성공: 상품 리스트 반환
  return List<Map<String, dynamic>>.from(response);
}
