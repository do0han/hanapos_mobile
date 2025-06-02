import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> sendResetEmail() async {
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final email = emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        setState(() => message = '유효한 이메일을 입력하세요.');
        return;
      }
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      setState(() => message = '비밀번호 재설정 메일이 발송되었습니다.');
    } catch (e) {
      setState(() => message = '오류: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : sendResetEmail,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('재설정 메일 보내기'),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
