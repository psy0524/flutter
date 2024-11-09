import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChecklistDetailPage extends StatefulWidget {
  final String title;
  final bool inspection;
  final String checklistId;  // checklistId 추가

  ChecklistDetailPage({
    required this.title,
    required this.inspection,
    required this.checklistId,  // checklistId를 받도록 추가
  });

  @override
  _ChecklistDetailPageState createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  late Future<List<ChecklistItem>> checklistItemsFuture; // checklistItems를 Future로 관리

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
    // Firestore에서 체크리스트 템플릿 데이터를 가져오는 부분
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checklist')
        .doc(widget.checklistId)  // 실제 checklistId를 사용
        .collection('template')
        .get();

    List<ChecklistItem> items = snapshot.docs.map((doc) {
      return ChecklistItem(
        number: doc['check_seq'], // check_seq를 number로 사용
        question: doc['check_contents'], // check_contents를 question으로 사용
      );
    }).toList();

    return items;
  }

  @override
  void initState() {
    super.initState();
    checklistItemsFuture = _fetchChecklistItems(); // checklistItems 데이터 비동기적으로 가져오기
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

          // Firestore에서 받아온 checklist 항목들
          final checklistItems = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 점검표 정보 섹션 추가
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
                    crossAxisAlignment: CrossAxisAlignment.center, // 모든 요소를 가운데 정렬
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center, // 텍스트 가운데 정렬
                      ),
                      SizedBox(height: 8),
                      Text(
                        '일시: $today',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center, // 텍스트 가운데 정렬
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
                          textAlign: TextAlign.center, // 텍스트 가운데 정렬
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 체크리스트 항목들
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
                                groupValue: item.selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    item.selectedOption = value;
                                  });
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
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                          ),
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
                        if (item.selectedOption == '부적합') ...[
                          SizedBox(height: 16),
                          Text('부적합 사유:', style: TextStyle(fontSize: 16)),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: '부적합 사유를 작성해주세요.',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      // 작성완료 버튼을 하단에 고정
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
            print("점검 완료 버튼 클릭됨");
          },
          child: Text('점검 완료', style: TextStyle(fontSize: 18)),
        ),
      )
          : null, // inspection이 true일 때는 bottomNavigationBar가 없음
    );
  }
}

// 체크리스트 데이터 모델 정의
class ChecklistItem {
  final int number;
  final String question;
  final List<String> options;
  String? selectedOption;

  ChecklistItem({
    required this.number,
    required this.question,
    this.options = const ['적합', '부적합'],
    this.selectedOption,
  });
}
