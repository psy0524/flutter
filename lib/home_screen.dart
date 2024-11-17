import 'package:flutter/material.dart'; // Flutter 기본 위젯 라이브러리
import 'package:flutter/painting.dart'; // Flutter 페인팅 관련 라이브러리
import 'package:untitled/page/notice_page.dart'; // 공지사항 페이지 임포트
import 'package:untitled/page/safetyVoice_page.dart'; // 안전보이스 페이지 임포트
import 'package:untitled/page/checkList_page.dart'; // 체크리스트 페이지 임포트
import 'package:untitled/page/riskAssessment_page.dart'; // 위험성 평가 페이지 임포트
import 'package:untitled/page/education_page.dart'; // 교육현황 페이지 임포트
import 'package:untitled/page/seriousAccidentNotification_page.dart'; // 중대재해 알림 페이지 임포트
import 'main.dart'; // 로그인 페이지 임포트

// 홈 화면을 구성하는 StatelessWidget
class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData; // 사용자 정보를 담는 Map

  HomeScreen({required this.userData}); // 생성자에서 사용자 정보 전달받기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        toolbarHeight: 40.0, // 앱바 높이를 40으로 설정
        title: Text(''), // 제목 비우기
        centerTitle: true, // 제목을 가운데 정렬
        backgroundColor: Color(0xff35455e), // 앱바 배경색 설정
        actions: [
          // 로그아웃 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 버튼 여백
            child: OutlinedButton(
              onPressed: () {
                // 로그아웃 기능
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 1.0), // 버튼 테두리 스타일 설정
              ),
              child: Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.white, // 텍스트 색상
                  fontSize: 13, // 텍스트 크기
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 타이틀 이미지 추가
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.asset('assets/title_image_navy.png'), // 로컬 이미지 경로
            ),
            SizedBox(height: 13),
            // 사용자 정보 카드 위젯
            UserCard(userData: userData), // 유저 데이터 전달
            // 메뉴 버튼들 - 3열 GridView로 구성
            GridView.count(
              crossAxisCount: 3, // 한 행에 3개의 버튼 배치
              shrinkWrap: true, // GridView 크기를 자식 콘텐츠에 맞춤
              physics: NeverScrollableScrollPhysics(), // GridView 자체 스크롤 비활성화
              padding: const EdgeInsets.all(8.0),
              children: [
                // 각 메뉴 버튼 정의
                MenuButton(
                  icon: Icons.checklist,
                  label: '체크리스트',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChecklistPage(
                          userNm: userData['user_nm'], // 사용자 이름 전달
                          areaInCharge: userData['area_in_charge'] ?? '', // 책임 구역 전달
                        ),
                      ),
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.report,
                  label: '안전보이스',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SafetyVoicePage()),
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.campaign,
                  label: '공지사항',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoticePage(notices: notices)),
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.shield,
                  label: '위험성 평가',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RiskAssessmentPage()),
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.notifications,
                  label: '중대재해 알림',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SeriousAccidentNoticePage(SeriousAccidentNotices: SeriousAccidentNotices)),
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.menu_book,
                  label: '교육현황',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EducationPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 사용자 정보를 표시하는 카드 위젯
class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData; // 사용자 정보를 담는 Map

  UserCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0, // 그림자 깊이
      color: Colors.white, // 배경색
      margin: EdgeInsets.all(16.0), // 외부 여백
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
        side: BorderSide(color: Colors.yellow, width: 1.5), // 노란색 테두리
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40, // 프로필 사진 크기
              backgroundImage: AssetImage('assets/user_image.png'), // 사용자 이미지
            ),
            SizedBox(width: 20),
            // 사용자 정보 텍스트
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['user_nm'] ?? '이름 없음', // 이름
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['user_id'] ?? 'ID 없음', // ID
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  userData['department'] ?? '부서 없음', // 부서
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  userData['area_in_charge'] ?? '책임 구역 없음', // 책임 구역
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 메뉴 버튼 위젯
class MenuButton extends StatelessWidget {
  final IconData icon; // 아이콘
  final String label; // 버튼 레이블
  final Function onPressed; // 버튼 클릭 시 실행할 함수

  MenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(), // 클릭 이벤트
      child: Card(
        elevation: 2.0, // 그림자 깊이
        color: Colors.white, // 배경색
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
          side: BorderSide(color: Colors.yellow, width: 1.5), // 노란색 테두리
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
          children: [
            Icon(
              icon,
              size: 40, // 아이콘 크기
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 14), // 텍스트 스타일
            ),
          ],
        ),
      ),
    );
  }
}
