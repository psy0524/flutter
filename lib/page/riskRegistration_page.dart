import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지
import 'package:untitled/page/newRiskEvaluation_page.dart'; // 새로운 위험성 평가 페이지 참조

class RiskRegistrationPage extends StatefulWidget {
  @override
  _RiskRegistrationPageState createState() => _RiskRegistrationPageState();
}

class _RiskRegistrationPageState extends State<RiskRegistrationPage> {
  List<Map<String, dynamic>> riskEvaluations = []; // 위험성 평가 항목을 저장하는 리스트
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스

  // 사용자 입력 값 저장을 위한 변수
  String? selectedPlace; // 사업장
  String? selectedEvalType; // 평가 종류
  String? companyName; // 업체명
  String? siteName; // 현장명
  String? evaluator; // 평가자

  // 새로운 항목을 추가하는 함수
  void _addNewRiskEvaluation(Map<String, dynamic> newEvaluation) {
    newEvaluation['seqNo'] = riskEvaluations.length + 1; // 항목의 순번 설정

    setState(() {
      riskEvaluations.add(newEvaluation); // 새로운 평가 항목을 리스트에 추가
    });
  }

  // 작성 완료 버튼 클릭 시 Firestore에 데이터 저장
  Future<void> _saveToFirestore() async {
    try {
      // 필수 입력값 확인
      if (selectedPlace == null || selectedEvalType == null || companyName == null || siteName == null || evaluator == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("모든 필드를 입력해주세요.")));
        return;
      }

      // RiskLevel3 컬렉션에 문서 추가
      DocumentReference riskLevel3DocRef = await _firestore.collection('RiskLevel3').add({
        'place_nm': selectedPlace, // 사업장명
        'eval_type_nm': selectedEvalType, // 평가 종류
        'scene_nm': companyName, // 업체명
        'eval_trgt_nm': siteName, // 평가 대상
        'evaluators': evaluator, // 평가자
        'status_nm': '등록', // 초기 상태
        'status': '1', // 상태 코드
        'wrt_date': DateFormat('yyyy-MM-dd').format(DateTime.now()), // 작성 날짜
      });

      // eval_id 필드를 RiskLevel3 문서 ID로 업데이트
      await riskLevel3DocRef.update({
        'eval_id': riskLevel3DocRef.id, // Firestore에서 생성된 문서 ID
      });

      // riskLevel3Detail 컬렉션에 각 항목 저장
      for (var evaluation in riskEvaluations) {
        // 날짜 포맷을 적용하여 저장
        String formattedDueDate = DateFormat('yyyy-MM-dd').format(evaluation['scheduledDate']);
        String formattedCmpDate = DateFormat('yyyy-MM-dd').format(evaluation['completionDate']);

        await _firestore.collection('riskLevel3Detail').add({
          'eval_id': riskLevel3DocRef.id, // RiskLevel3의 ID를 참조
          'seq_no': evaluation['seqNo'], // 순번
          'unit_work': evaluation['unitOperation'], // 단위 작업
          'risk_fctr': evaluation['riskFactor'], // 위험 요인
          'risk_grade_nm': evaluation['riskLevel'], // 위험 수준
          'impr_msrs': evaluation['measure'], // 개선 대책
          'impr_due_date': formattedDueDate, // 개선 예정일
          'impr_cmp_date': formattedCmpDate, // 개선 완료일
          'impr_mngr': evaluation['manager'], // 개선 담당자
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 완료")));
      Navigator.pop(context); // 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 키보드가 올라왔을 때 화면 조정을 허용
      appBar: AppBar(
        title: Text('위험성 평가 등록'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사업장 및 평가종류 드롭다운 필드
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '사업장',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    items: ['본관', '공학관', '보건의료관', '스포츠과학관', '원화관', '인문관', '자연과학관']
                        .map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPlace = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '평가종류',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    items: ['최초', '정기', '수시']
                        .map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEvalType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 업체명 입력 필드
            TextFormField(
              decoration: InputDecoration(
                labelText: '업체명',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              onChanged: (value) {
                companyName = value;
              },
            ),
            SizedBox(height: 16),
            // 현장명 입력 필드
            TextFormField(
              decoration: InputDecoration(
                labelText: '현장명(평가대상)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              onChanged: (value) {
                siteName = value;
              },
            ),
            SizedBox(height: 16),
            // 평가자 입력 필드
            TextFormField(
              decoration: InputDecoration(
                labelText: '평가자',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              onChanged: (value) {
                evaluator = value;
              },
            ),
            SizedBox(height: 16),
            // 위험성 평가 추가 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('위험성 평가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_outlined, color: Colors.blue),
                  onPressed: () async {
                    final newEvaluation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewRiskEvaluationPage(), // 새로운 위험성 평가 페이지로 이동
                      ),
                    );
                    if (newEvaluation != null) {
                      _addNewRiskEvaluation(newEvaluation); // 새로운 평가 항목 추가
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // 추가된 위험성 평가 항목 표시
            ...riskEvaluations.map((evaluation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                // 평가 항목을 카드로 표시
              ),
            )).toList(),
          ],
        ),
      ),
      // 하단 작성 완료 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(16),
            shape: StadiumBorder(),
          ),
          onPressed: _saveToFirestore, // 작성 완료 시 데이터 저장 함수 호출
          child: Text('작성 완료', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
