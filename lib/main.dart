import 'package:flutter/material.dart'; // Flutter 기본 위젯 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리
import 'dart:convert'; // JSON 데이터 처리를 위한 라이브러리
import 'home_screen.dart'; // 로그인 성공 후 이동할 HomeScreen 위젯
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화 라이브러리
import 'firebase_options.dart'; // Firebase 설정 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크가 준비되었는지 확인
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화 (환경별 설정)
  );
  runApp(MyApp()); // 앱 실행
}

// 애플리케이션의 메인 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App', // 앱 이름
      theme: ThemeData(primarySwatch: Colors.blue), // 앱 테마 설정
      home: LoginPage(), // 초기 화면으로 LoginPage 설정
    );
  }
}

// 로그인 화면 위젯
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// LoginPage의 상태를 관리하는 클래스
class _LoginPageState extends State<LoginPage> {
  // 사용자 ID와 비밀번호 입력을 위한 텍스트 컨트롤러
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String message = ''; // 로그인 결과 메시지

  // 로그인 버튼 클릭 시 실행되는 함수
  Future<void> login() async {
    final String userId = userIdController.text; // 입력된 사용자 ID
    final String password = passwordController.text; // 입력된 비밀번호

    // 서버로 로그인 요청
    final response = await http.post(
      Uri.parse('http://localhost:3000/login'), // 로그인 API URL
      headers: {'Content-Type': 'application/json'}, // 요청 헤더
      body: json.encode({
        'user_id': userId, // 전송 데이터: 사용자 ID
        'password': password, // 전송 데이터: 비밀번호
      }),
    );

    if (response.statusCode == 200) {
      // 서버 응답이 성공적일 경우
      final data = json.decode(response.body); // 응답 JSON 데이터 파싱
      setState(() {
        message = data['message']; // 성공 메시지 설정
      });

      // 로그인 성공 시 HomeScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userData: {
              'user_id': data['user_id'], // 사용자 ID
              'user_nm': data['user_nm'], // 사용자 이름
              'department': data['department'], // 부서
              'area_in_charge': data['area_in_charge'], // 담당 지역
            },
          ),
        ),
      );
    } else {
      // 서버 응답이 실패일 경우
      setState(() {
        message = '로그인 실패: ${response.body}'; // 에러 메시지 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')), // 상단 바 제목
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백 설정
        child: Column(
          children: [
            // 사용자 ID 입력 필드
            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: '사용자 ID'),
            ),
            // 비밀번호 입력 필드 (숨김 처리)
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true, // 입력 값 숨기기
            ),
            SizedBox(height: 20), // 공간 추가
            // 로그인 버튼
            ElevatedButton(
              onPressed: login, // 버튼 클릭 시 login 함수 실행
              child: Text('로그인'),
            ),
            SizedBox(height: 20), // 공간 추가
            Text(message), // 로그인 결과 메시지 표시
          ],
        ),
      ),
    );
  }
}
