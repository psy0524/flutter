import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // 파일 처리 및 이미지 저장을 위한 패키지

// SafetyVoicePage 클래스는 사용자가 안전보이스를 작성할 수 있는 페이지를 정의
class SafetyVoicePage extends StatefulWidget {
  @override
  _SafetyVoicePageState createState() => _SafetyVoicePageState();
}

// SafetyVoicePage의 상태 클래스
class _SafetyVoicePageState extends State<SafetyVoicePage> {
  List<File> _selectedImages = []; // 선택된 이미지를 저장하는 리스트
  final ImagePicker _picker = ImagePicker(); // 이미지를 선택하기 위한 ImagePicker 인스턴스

  // 이미지를 카메라 또는 앨범에서 선택하는 함수
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source); // 이미지 선택 대화상자 표시

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path)); // 선택된 이미지 파일을 리스트에 추가
      });
    }
  }

  // 선택된 이미지를 삭제하는 함수
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index); // 지정된 인덱스의 이미지를 리스트에서 삭제
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 화면 배경색을 흰색으로 설정
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면을 조정
      appBar: AppBar(
        title: Text('안전보이스 작성'), // 화면 상단 제목
        centerTitle: true, // 제목을 가운데 정렬
        backgroundColor: Colors.white, // 앱바 배경색
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // 화면 여백 설정
        child: Column(
          children: [
            // 사업장 및 작성구분 Dropdown 메뉴
            Row(
              children: [
                // 사업장 선택 Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '사업장', // 레이블 텍스트
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), // 둥근 테두리
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    items: ['본관', '공학관', '보건의료관', '스포츠과학관', '원화관', '인문관', '자연과학관']
                        .map((label) => DropdownMenuItem(
                      child: Text(label), // 드롭다운 아이템
                      value: label,
                    )).toList(),
                    onChanged: (value) {}, // 값이 변경될 때 실행할 함수
                  ),
                ),
                SizedBox(width: 16), // 항목 간 간격
                // 작성구분 선택 Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '작성구분',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    items: ['안전신고', '안전제안']
                        .map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    )).toList(),
                    onChanged: (value) {}, // 값 변경 시 동작
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // 위젯 간 간격

            // 제목 입력 필드
            TextFormField(
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(), // 테두리 스타일
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
            SizedBox(height: 16),

            // 내용 입력 필드
            TextFormField(
              decoration: InputDecoration(
                labelText: '내용',
                hintText: '접수된 안전보이스는 순차적으로 조치를 취하고 있습니다. 내용을 상세히 기재해 주셔야 정확한 조치가 가능합니다.',
                hintStyle: TextStyle(color: Colors.grey[400]), // 힌트 스타일
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
              ),
              maxLines: 7, // 최대 줄 수
            ),
            SizedBox(height: 20),

            // 사진 첨부 설명 텍스트
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '사진 첨부 (최대 3장)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 5),

            // 이미지 추가 및 선택된 이미지 목록
            Row(
              children: [
                // 이미지 추가 버튼
                GestureDetector(
                  onTap: () {
                    _showImageSourceActionSheet(); // 이미지 소스 선택 대화상자 표시
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.add_a_photo, size: 40), // 추가 아이콘
                  ),
                ),
                SizedBox(width: 16),
                // 선택된 이미지 리스트 (최대 3장)
                Expanded(
                  child: Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // 가로 스크롤
                      itemCount: _selectedImages.length, // 이미지 개수
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // 이미지 카드
                            Container(
                              margin: EdgeInsets.only(right: 16),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey), // 테두리
                              ),
                              child: Image.file(_selectedImages[index], fit: BoxFit.cover), // 이미지 표시
                            ),
                            // 이미지 삭제 버튼
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index), // 이미지 삭제
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5), // 반투명 배경
                                  ),
                                  child: Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // 작성 완료 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(16),
            shape: StadiumBorder(), // 둥근 버튼
          ),
          onPressed: () {
            // 작성 완료 버튼 클릭 시 동작
          },
          child: Text('작성 완료', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  // 이미지 소스 선택 다이얼로그
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt), // 카메라 아이콘
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera); // 카메라 촬영 선택
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album), // 앨범 아이콘
                title: Text('앨범에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery); // 갤러리에서 선택
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// 앱 실행
void main() => runApp(MaterialApp(home: SafetyVoicePage()));
