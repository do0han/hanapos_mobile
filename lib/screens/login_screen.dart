import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storeNameController = TextEditingController();

  Future<void> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print('로그인 성공: ${response.user!.id}');
        // 로그인 성공 시 HomeScreen으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('로그인 실패: 알 수 없는 이유');
      }
    } catch (e) {
      print('로그인 에러: $e');
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
        // 회원가입 성공 시 바로 로그인 시도
        await signIn(email, password);
      } else {
        print('회원가입 실패: 알 수 없는 이유');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('에러'),
            content: Text('회원가입 실패: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> signUpWithAutoStore(
      String email, String password, String storeName) async {
    try {
      // 1. 매장(store) 자동 생성
      final storeRes = await Supabase.instance.client
          .from('stores')
          .insert({
            'name': storeName,
            // ...필요한 필드 추가
          })
          .select()
          .single();
      final storeId = storeRes['id'] as String;

      // 2. 회원가입
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        // 3. profiles에 store_id 자동 할당
        await Supabase.instance.client.from('profiles').update({
          'store_id': storeId,
        }).eq('id', user.id);
        print('회원가입 + 매장 생성 + store_id 자동 할당 완료');
        // 4. 회원가입 성공 시 자동 로그인
        await signIn(email, password);
      } else {
        print('회원가입 실패');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('에러'),
            content: Text('회원가입 실패: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인/회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(labelText: '매장명'),
            ),
            ElevatedButton(
              onPressed: () =>
                  signIn(emailController.text, passwordController.text),
              child: const Text('로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.length < 6) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('에러'),
                      content: const Text('비밀번호는 6자 이상이어야 합니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                signUpWithAutoStore(
                  emailController.text,
                  passwordController.text,
                  storeNameController.text,
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
