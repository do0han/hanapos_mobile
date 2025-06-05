import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storeNameController = TextEditingController();
  String _selectedRole = 'cashier';

  Future<void> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print('로그인 성공: \\${response.user!.id}');
        // 로그인 성공 시 JWT 토큰 추출
        final session = Supabase.instance.client.auth.currentSession;
        final jwt = session?.accessToken;
        // 로그인 성공 시 role 조회 후 HomeScreen으로 이동
        final userId = response.user!.id;
        final supabaseService = SupabaseService();
        final role = await supabaseService.getUserRole(userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(jwtToken: jwt!),
          ),
        );
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
        print('회원가입 성공: \\${response.user!.id}');
        final user = response.user!;
        // profiles row 존재 여부 확인
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (profile == null) {
          // 없으면 insert
          await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'role': _selectedRole,
            // store_id는 signUpWithAutoStore에서만 사용
          });
        } else {
          // 있으면 update
          await Supabase.instance.client.from('profiles').update({
            'role': _selectedRole,
          }).eq('id', user.id);
        }
        // 회원가입 성공 시 바로 로그인 시도
        await signIn(email, password);
      } else {
        print('회원가입 실패: 알 수 없는 이유');
      }
    } catch (e) {
      String errorMsg = '회원가입 실패: $e';
      // 이미 가입된 이메일 처리
      if (e.toString().contains('user_already_exists') ||
          e.toString().contains('User already registered') ||
          e.toString().contains('statusCode: 422')) {
        errorMsg = '이미 가입된 이메일입니다.';
      }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('에러'),
            content: Text(errorMsg),
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
        // profiles row 존재 여부 확인
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (profile == null) {
          // 없으면 insert
          await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'store_id': storeId,
            'role': _selectedRole,
          });
        } else {
          // 있으면 update
          await Supabase.instance.client.from('profiles').update({
            'store_id': storeId,
            'role': _selectedRole,
          }).eq('id', user.id);
        }
        print('회원가입 + 매장 생성 + store_id, role 자동 할당 완료');
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

  Future<void> signInWithGitHub() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.auth.signInWithOAuth(OAuthProvider.github);
    // 로그인 완료 후 access_token 추출
    final session = supabase.auth.currentSession;
    print('GitHub access_token: ${session?.accessToken}');
    // 필요하면 HomeScreen 등으로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인/회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            DropdownButton<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'cashier', child: Text('캐셔')),
                DropdownMenuItem(value: 'owner', child: Text('오너')),
                DropdownMenuItem(value: 'manager', child: Text('매니저')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
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
            ElevatedButton(
              onPressed: () async {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  await Supabase.instance.client
                      .from('profiles')
                      .update({'role': 'owner'}) // 예: owner로 변경
                      .eq('id', user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('역할이 변경되었습니다!')),
                  );
                }
              },
              child: const Text('역할을 owner로 변경'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text('비밀번호 찾기'),
              ),
            ),
            ElevatedButton(
              onPressed: signInWithGitHub,
              child: const Text('GitHub로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
