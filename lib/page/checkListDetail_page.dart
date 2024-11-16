import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChecklistDetailPage extends StatefulWidget {
  final String title;
  final bool inspection;
  final String checklistId;

  ChecklistDetailPage({
    required this.title,
    required this.inspection,
    required this.checklistId,
  });

  @override
  _ChecklistDetailPageState createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  final ImagePicker _picker = ImagePicker();
  late Future<List<ChecklistItem>> checklistItemsFuture;

  // 각 항목마다 텍스트 필드를 관리할 컨트롤러를 선언
  Map<int, TextEditingController> _controllers = {};
  Map<int, String> _checkDetails = {}; // 각 항목의 라디오 버튼 선택 상태를 관리
  Map<int, List<File>> _selectedImagesMap = {};  // 각 항목의 이미지를 저장할 Map

  Future<void> _pickImage(ChecklistItem item) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (!_selectedImagesMap.containsKey(item.number)) {
          _selectedImagesMap[item.number] = [];
        }
        _selectedImagesMap[item.number]!.add(File(pickedFile.path));  // 해당 항목에 이미지를 추가
      });
    }
  }

  void _removeImage(ChecklistItem item, int index) {
    setState(() {
      _selectedImagesMap[item.number]!.removeAt(index);  // 해당 항목에서 이미지를 삭제
    });
  }

  Future<List<ChecklistItem>> _fetchChecklistItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checklist')
        .doc(widget.checklistId)
        .collection('template')
        .orderBy('check_seq') // check_seq를 기준으로 오름차순 정렬
        .get();

    List<ChecklistItem> items = snapshot.docs.map((doc) {
      return ChecklistItem(
        number: doc['check_seq'],  // check_seq 값 사용
        question: doc['check_contents'],
        checkDetail: doc['check_detail'] ?? '적합',
        actnContents: doc['actn_contents'] ?? '',
      );
    }).toList();

    // 각 항목마다 텍스트 필드를 관리할 컨트롤러 초기화
    for (var item in items) {
      _controllers[item.number] = TextEditingController(text: item.actnContents);
      _checkDetails[item.number] = item.checkDetail; // 초기 선택 상태 저장
      _selectedImagesMap[item.number] = [];  // 각 항목마다 이미지 리스트 초기화
    }

    return items;
  }

  Future<void> _saveChecklistItem(ChecklistItem item) async {
    try {
      await FirebaseFirestore.instance
          .collection('checklist')
          .doc(widget.checklistId)
          .collection('template')
          .doc((item.number - 1).toString()) // check_seq에서 1을 빼서 문서 ID로 사용
          .update({
        'check_detail': item.checkDetail,
        'actn_contents': item.actnContents ?? '',
      });

    } catch (e) {
      print("문서 업데이트 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문서 업데이트 실패: $e')),
      );
    }
  }

  Future<void> _completeInspection() async {
    try {
      await FirebaseFirestore.instance
          .collection('checklist')
          .doc(widget.checklistId)
          .update({'check_yn': '점검'});  // 점검 완료 업데이트
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('점검이 완료되었습니다.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("점검 완료 업데이트 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('점검 완료 업데이트 실패: $e')),
      );
    }
  }

  bool _isAllItemsChecked() {
    return _checkDetails.values.every((value) => value == '적합' || value == '부적합');
  }

  @override
  void initState() {
    super.initState();
    checklistItemsFuture = _fetchChecklistItems();
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('체크리스트 작성'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ChecklistItem>>(
        future: checklistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('템플릿 데이터가 없습니다.'));
          }

          final checklistItems = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 16.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.black, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '일시: $today',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
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
                          '${widget.inspection ? "점검 완료" : "점검 미완료"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.inspection ? Colors.blueAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...checklistItems.map((item) {
                return Card(
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.number}. ${item.question}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: item.options.map<Widget>((option) {
                            return Expanded(
                              child: RadioListTile(
                                title: Text(option),
                                value: option,
                                groupValue: _checkDetails[item.number], // 현재 체크된 값 사용
                                onChanged: (value) {
                                  setState(() {
                                    _checkDetails[item.number] = value.toString();
                                    item.checkDetail = value.toString(); // 항목 업데이트
                                    if (item.checkDetail == '부적합') {
                                      item.actnContents = _controllers[item.number]!.text;
                                    } else {
                                      item.actnContents = ''; // '적합'일 경우 부적합 사유 비워두기
                                    }
                                  });
                                  _saveChecklistItem(item); // 선택한 값을 저장
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        Text('사진 첨부:', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage(item),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: Icon(Icons.add_a_photo, size: 40),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(_selectedImagesMap[item.number]!.length, (index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 16),
                                          width: 100,
                                          height: 100,
                                          child: Image.file(
                                            _selectedImagesMap[item.number]![index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(item, index),
                                            child: Icon(Icons.remove_circle, color: Colors.red, size: 24),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_checkDetails[item.number] == '부적합')
                          TextField(
                            controller: _controllers[item.number],
                            decoration: InputDecoration(
                              labelText: '부적합 사유', // 라벨 텍스트
                              hintText: '부적합 사유를 입력하세요', // 힌트 텍스트 추가
                            ),
                            onChanged: (value) {
                              setState(() {
                                item.actnContents = value;
                              });
                              _saveChecklistItem(item); // 부적합 사유 업데이트
                            },
                          ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
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
            if (_isAllItemsChecked()) {
              _completeInspection();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('모든 항목을 체크해 주세요.')),
              );
            }
          },
          child: Text('점검 완료', style: TextStyle(fontSize: 18)),
        ),
      )
          : null,
    );
  }
}

class ChecklistItem {
  final int number;
  final String question;
  String checkDetail;
  String? actnContents;
  List<String> options = ['적합', '부적합'];

  ChecklistItem({
    required this.number,
    required this.question,
    required this.checkDetail,
    this.actnContents,
  });
}
