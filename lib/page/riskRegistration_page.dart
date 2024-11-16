import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지
import 'package:untitled/page/newRiskEvaluation_page.dart';

class RiskRegistrationPage extends StatefulWidget {
  @override
  _RiskRegistrationPageState createState() => _RiskRegistrationPageState();
}

class _RiskRegistrationPageState extends State<RiskRegistrationPage> {
  List<Map<String, dynamic>> riskEvaluations = []; // 위험성 평가 항목을 저장하는 리스트
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 입력 값 저장을 위한 변수
  String? selectedPlace; // 사업장
  String? selectedEvalType; // 평가 종류
  String? companyName; // 업체명
  String? siteName; // 현장명
  String? evaluator; // 평가자

  // 새로운 항목을 추가하는 함수
  void _addNewRiskEvaluation(Map<String, dynamic> newEvaluation) {
    newEvaluation['seqNo'] = riskEvaluations.length + 1;

    setState(() {
      riskEvaluations.add(newEvaluation);
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
        'place_nm': selectedPlace,
        'eval_type_nm': selectedEvalType,
        'scene_nm': companyName,
        'eval_trgt_nm': siteName,
        'evaluators': evaluator,
        'status_nm': '등록', // 초기 상태
        'status': 1, // status 필드를 1로 추가
        'wrt_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      // eval_id 필드를 RiskLevel3 문서 ID로 업데이트
      await riskLevel3DocRef.update({
        'eval_id': riskLevel3DocRef.id,
      });

      // riskLevel3Detail 컬렉션에 각 항목 저장
      for (var evaluation in riskEvaluations) {
        // 날짜 포맷을 적용하여 저장
        String formattedDueDate = DateFormat('yyyy-MM-dd').format(evaluation['scheduledDate']);
        String formattedCmpDate = DateFormat('yyyy-MM-dd').format(evaluation['completionDate']);

        await _firestore.collection('riskLevel3Detail').add({
          'eval_id': riskLevel3DocRef.id, // RiskLevel3의 ID를 저장
          'seq_no': evaluation['seqNo'],
          'unit_work': evaluation['unitOperation'],
          'risk_fctr': evaluation['riskFactor'],
          'risk_grade_nm': evaluation['riskLevel'],
          'impr_msrs': evaluation['measure'],
          'impr_due_date': formattedDueDate,  // 날짜 포맷 적용
          'impr_cmp_date': formattedCmpDate,  // 날짜 포맷 적용
          'impr_mngr': evaluation['manager'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 완료")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
                        builder: (context) => NewRiskEvaluationPage(),
                      ),
                    );
                    if (newEvaluation != null) {
                      _addNewRiskEvaluation(newEvaluation);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ...riskEvaluations.map((evaluation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                color: Colors.grey.shade100, // 카드 배경 색상 설정
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // 모서리 둥글게 설정
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("단위작업", evaluation['unitOperation']),
                      _buildDetailRow("유해.위험요인", evaluation['riskFactor']),
                      Divider(thickness: 1, color: Colors.grey.shade300), // 구분선 추가
                      SizedBox(height: 16),

                      // 위험수준 라디오 버튼 추가
                      Text(
                        '위험수준:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['상', '중', '하'].map((level) {
                          return Row(
                            children: [
                              Radio<String>(
                                value: level,
                                groupValue: evaluation['riskLevel'], // 선택된 위험 수준과 일치하는지 확인
                                onChanged: (value) {
                                  setState(() {
                                    evaluation['riskLevel'] = value; // 위험 수준 변경 반영
                                  });
                                },
                              ),
                              Text(level, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                            ],
                          );
                        }).toList(),
                      ),
                      Divider(thickness: 1, color: Colors.grey.shade300), // 구분선 추가
                      SizedBox(height: 8),

                      _buildDetailRow("개선 대책", evaluation['measure']),
                      _buildDetailRow("개선 담당자", evaluation['manager']),
                      SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '개선 예정일:',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(evaluation['scheduledDate']),
                                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '개선 완료일:',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(evaluation['completionDate']),
                                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(16),
            shape: StadiumBorder(),
          ),
          onPressed: _saveToFirestore,
          child: Text('작성 완료', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  // 세부 정보를 담은 행을 만드는 위젯
  Widget _buildDetailRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        Text(
          value ?? '-',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
