import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiskDetailPage extends StatefulWidget {
  final String company;
  final String title;
  final String workplace;
  final String type;
  final String date;
  final String name;
  final bool inspection;
  final String evalId;  // 추가된 evalId 필드

  RiskDetailPage({
    required this.company,
    required this.title,
    required this.workplace,
    required this.type,
    required this.date,
    required this.name,
    required this.inspection,
    required this.evalId,  // evalId 전달
  });

  @override
  _RiskDetailPageState createState() => _RiskDetailPageState();
}

class _RiskDetailPageState extends State<RiskDetailPage> {
  // Firestore에서 데이터를 불러오는 함수
  Future<List<RiskItem>> _getRiskItemsFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('riskLevel3Detail')
        .where('eval_id', isEqualTo: widget.evalId)  // evalId 필터링
        .get();

    return snapshot.docs.map((doc) {
      return RiskItem.fromFirestore(doc);
    }).toList();
  }

  // Firestore에 데이터를 업데이트하는 함수
  Future<void> _updateRiskGrade(RiskItem item, String grade) async {
    await FirebaseFirestore.instance
        .collection('riskLevel3Detail')
        .doc(item.id)  // Firestore 문서 ID
        .update({'risk_grade_nm': grade});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('위험성 평가(3단계)'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 위험성평가 정보 섹션
          Card(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.black, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.inspection ? Colors.blueAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.inspection ? Colors.blueAccent : Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${widget.inspection ? "결재 상신" : "결재 대기"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.inspection ? Colors.blueAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1.5, height: 20),
                  SizedBox(height: 8),
                  _buildDetailRow("업체명", widget.company),
                  _buildDetailRow("사업장", widget.workplace),
                  _buildDetailRow("평가 종류", widget.type),
                  _buildDetailRow("일시", widget.date),
                  _buildDetailRow("평가자", widget.name),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 위험성평가 데이터 항목들
          FutureBuilder<List<RiskItem>>(
            future: _getRiskItemsFromFirestore(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('데이터 없음'));
              } else {
                List<RiskItem> riskItems = snapshot.data!;
                return Column(
                  children: riskItems.map((item) {
                    return Card(
                      color: Colors.grey.shade100,
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow("단위작업", item.unitOperation),
                            _buildDetailRow("유해.위험요인", item.riskFactor),
                            Divider(thickness: 1, color: Colors.grey.shade300), // 구분선 추가
                            SizedBox(height: 16),
                            Text(
                              '위험수준: ',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                            Row(
                              children: ['상', '중', '하'].map<Widget>((option) {
                                return Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(option, style: TextStyle(fontSize: 14)),
                                    value: option,
                                    groupValue: item.risk_grade_nm,  // 선택된 값
                                    onChanged: (value) {
                                      setState(() {
                                        item.risk_grade_nm = value.toString();  // 값 변경
                                      });
                                      _updateRiskGrade(item, value.toString());  // Firestore에 업데이트
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                            Divider(thickness: 1, color: Colors.grey.shade300), // 구분선 추가
                            SizedBox(height: 8),
                            _buildDetailRow("개선 대책", item.measure),
                            _buildDetailRow("개선 담당자", item.manager),
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
                                      item.scheduledDate,
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
                                      item.completionDate,
                                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: widget.inspection == false
          ? Padding(
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
            print("결재 상신 버튼 클릭됨");
          },
          child: Text('결재 상신', style: TextStyle(fontSize: 18)),
        ),
      )
          : null, // inspection이 true일 때는 bottomNavigationBar가 없음
    );
  }

  // 위험성평가 정보 세부 항목 생성 함수
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class RiskItem {
  final String id;
  final String unitOperation;
  final String riskFactor;
  String risk_grade_nm;  // 위험수준 값
  final String measure;
  final String scheduledDate;
  final String completionDate;
  final String manager;

  RiskItem({
    required this.id,
    required this.unitOperation,
    required this.riskFactor,
    required this.risk_grade_nm,
    required this.measure,
    required this.scheduledDate,
    required this.completionDate,
    required this.manager,
  });

  factory RiskItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RiskItem(
      id: doc.id,
      unitOperation: data['unit_work'] ?? '',
      riskFactor: data['risk_fctr'] ?? '',
      risk_grade_nm: data['risk_grade_nm'] ?? '',
      measure: data['impr_msrs'] ?? '',
      scheduledDate: data['impr_due_date'] ?? '',
      completionDate: data['impr_cmp_date'] ?? '',
      manager: data['impr_mngr'] ?? '',
    );
  }
}
