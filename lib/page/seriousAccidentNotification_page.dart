import 'package:flutter/material.dart';

// 중대재해 알림 페이지를 나타내는 StatelessWidget
class SeriousAccidentNoticePage extends StatelessWidget {
  final List<SeriousAccidentNotice> SeriousAccidentNotices; // 중대재해 알림 목록

  // 생성자에서 중대재해 알림 데이터를 전달받음
  SeriousAccidentNoticePage({required this.SeriousAccidentNotices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: Text('중대재해 알림'), // 앱바 제목
        centerTitle: true, // 제목을 가운데 정렬
        backgroundColor: Colors.white, // 앱바 배경색
      ),
      body: ListView.builder(
        // 중대재해 알림 데이터를 기반으로 동적 리스트 생성
        itemCount: SeriousAccidentNotices.length, // 항목 개수
        itemBuilder: (context, index) {
          final notice = SeriousAccidentNotices[index]; // 현재 항목 데이터 가져오기
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // 카드 여백
            child: Card(
              color: Colors.grey.shade100, // 카드 배경색
              child: ExpansionTile(
                // 제목과 작성일 표시
                title: Text(notice.title), // 알림 제목
                subtitle: Text(notice.date), // 작성일
                children: [
                  // 알림 내용 표시
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(notice.content),
                  ),
                  // 이미지 표시 (이미지가 있는 경우만)
                  notice.image.isNotEmpty
                      ? Image.network(notice.image)
                      : Container(), // 이미지가 없으면 빈 컨테이너 반환
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 중대재해 알림 데이터를 나타내는 모델 클래스
class SeriousAccidentNotice {
  final String title; // 제목
  final String date; // 작성일
  final String content; // 내용
  final String image; // 이미지 URL (없을 경우 빈 문자열)

  // 생성자를 통해 필수 데이터를 전달받음
  SeriousAccidentNotice({
    required this.title,
    required this.date,
    required this.content,
    required this.image,
  });
}

// 중대재해 알림에 대한 샘플 데이터
List<SeriousAccidentNotice> SeriousAccidentNotices = [
  SeriousAccidentNotice(
    title: '서비스업 생활폐기물 수거 중 끼임', // 제목
    date: '2024-08-28', // 작성일
    content: """생활폐기물 수거 중 끼임

► 사고발생 원인
- (인적) 적재함에 탑승한 근로자의 위치를 확인하지 않은 상태에서 파워게이트 조작
- (탑승) 폐기물을 받아 적재하기 위해 적재함에 탑승한 채 이동함
- (신호) 작업자 간 신호 방법 부재
- (작업계획서) 화물자동차 상차 방법 작업계획서 미수립
""", // 알림 내용
    image: 'http://203.231.136.21:8001/imgupload/notice/17248185405244a7b5e960c40aa0f8bc92888b43f3ba0.png', // 이미지 URL
  ),
  // 추가 데이터 항목은 동일한 형식으로 정의 가능
];
