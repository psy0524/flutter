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
  List<File> _selectedImages = [];
  late Future<List<ChecklistItem>> checklistItemsFuture;

  // 각 항목마다 텍스트 필드를 관리할 컨트롤러를 선언
  Map<int, TextEditingController> _controllers = {};

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
    }

    return items;
  }

  Future<void> _saveChecklistItem(ChecklistItem item) async {
    try {
      // `check_seq - 1`을 사용하여 문서 ID로 저장
      await FirebaseFirestore.instance
          .collection('checklist')
          .doc(widget.checklistId)
          .collection('template')
          .doc((item.number - 1).toString()) // check_seq에서 1을 빼서 문서 ID로 사용
          .update({
        'check_detail': item.checkDetail,
        'actn_contents': item.actnContents ?? '',
      });

      // 성공적으로 저장된 후 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('부적합 사유가 저장되었습니다.')),
      );
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
          .update({'check_yn': '점검'});
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
                                groupValue: item.checkDetail,
                                onChanged: (value) {
                                  setState(() {
                                    item.checkDetail = value;
                                  });
                                  // 라디오 버튼을 선택할 때마다 "부적합 사유가 저장되었습니다." 메시지가 출력되지 않도록 수정
                                  if (item.checkDetail != '부적합') {
                                    // 부적합이 아닌 경우 메시지 출력하지 않음
                                    return;
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        Text('사진 첨부:', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
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
                                  children: List.generate(_selectedImages.length, (index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 16),
                                          width: 100,
                                          height: 100,
                                          child: Image.file(
                                            _selectedImages[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black.withOpacity(0.5),
                                              ),
                                              child: Icon(Icons.close, color: Colors.white, size: 20),
                                            ),
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
                        if (item.checkDetail == '부적합')
                          Column(
                            children: [
                              TextField(
                                controller: _controllers[item.number],
                                decoration: InputDecoration(
                                  hintText: '부적합 사유를 작성해주세요.',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(8.0),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    item.actnContents = value;
                                  });
                                },
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  _saveChecklistItem(item);
                                },
                                child: Text('부적합 사유 저장'),
                              ),
                            ],
                          ),
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
          onPressed: _completeInspection,
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
  final List<String> options;
  String? checkDetail;
  String? actnContents;

  ChecklistItem({
    required this.number,
    required this.question,
    this.options = const ['적합', '부적합'],
    this.checkDetail,
    this.actnContents,
  });
}
