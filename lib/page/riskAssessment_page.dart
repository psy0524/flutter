import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/page/riskDetail_page.dart';
import 'package:untitled/page/riskRegistration_page.dart';

class RiskAssessmentPage extends StatefulWidget {
  @override
  _RiskAssessmentPageState createState() => _RiskAssessmentPageState();
}

class _RiskAssessmentPageState extends State<RiskAssessmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("위험성 평가"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 위험성 평가 목록
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('RiskLevel3').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("데이터가 없습니다."));
                  }

                  // Firestore 데이터를 리스트로 변환
                  final riskItems = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: riskItems.length,
                    itemBuilder: (context, index) {
                      final riskData = riskItems[index];
                      // status가 "1"이면 대기, "2"이면 결재
                      bool isInspection = riskData['status'] == '2'; // 결재 여부 체크
                      String evalId = riskData['eval_id']; // eval_id 값을 Firestore에서 가져옵니다.

                      return _buildRiskAssessmentItem(
                        riskData['scene_nm'],       // company
                        riskData['eval_trgt_nm'],  // title
                        riskData['place_nm'],      // workplace
                        riskData['eval_type_nm'],  // type
                        riskData['wrt_date'],      // date
                        riskData['evaluators'],    // name
                        isInspection,              // inspection: status가 "2"일 때 결재, 아니면 대기
                        evalId,                    // evalId 전달
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // 하단에 등록 버튼 구현
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiskRegistrationPage()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_add, size: 24),
              SizedBox(width: 8),
              Text(
                '위험성 평가',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentItem(
      String company,
      String title,
      String workplace,
      String type,
      String date,
      String name,
      bool inspection,
      String evalId, // evalId 추가
      ) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: inspection ? Colors.blueAccent : Colors.grey,
          child: Text(
            inspection ? '결재' : '대기',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('사업장: $workplace', style: TextStyle(color: Colors.grey)),
            Text('평가일: $date', style: TextStyle(color: Colors.grey)),
            Text('평가자: $name', style: TextStyle(color: Colors.grey)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RiskDetailPage(
                company: company,
                title: title,
                workplace: workplace,
                type: type,
                date: date,
                name: name,
                inspection: inspection,
                evalId: evalId,  // evalId 전달
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: RiskAssessmentPage()));
}
