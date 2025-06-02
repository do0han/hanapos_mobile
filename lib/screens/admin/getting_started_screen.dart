import 'package:flutter/material.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 완료 상태는 API/Provider 등에서 받아와야 함. 일단 하드코딩 예시
    final checklist = [
      {
        'title': '매장 정보 입력',
        'done': false,
        'desc': '매장명, 연락처 등 기본 정보 입력',
        'action': () {},
      },
      {
        'title': '로고/배너 등록',
        'done': false,
        'desc': '브랜드 로고, 배너 이미지 업로드',
        'action': () {},
      },
      {
        'title': '상품 추가',
        'done': false,
        'desc': '판매할 상품을 등록하세요',
        'action': () {},
      },
      {
        'title': '직원 초대',
        'done': false,
        'desc': '직원을 초대하고 권한을 부여하세요',
        'action': () {},
      },
      {
        'title': '결제/도메인 설정',
        'done': false,
        'desc': '결제수단, 도메인 등 필수 설정',
        'action': () {},
      },
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Getting Started',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...checklist.map((item) => Card(
                  child: ListTile(
                    leading: Icon(
                        item['done']!
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item['done']! ? Colors.green : Colors.grey),
                    title: Text(item['title'] as String),
                    subtitle: Text(item['desc'] as String),
                    trailing: ElevatedButton(
                      onPressed: item['action'] as void Function(),
                      child: Text(item['done']! ? '완료' : '바로가기'),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
