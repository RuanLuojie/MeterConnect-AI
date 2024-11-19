import 'package:flutter/material.dart';

class IssueFeedbackScreen extends StatefulWidget {
  @override
  _IssueFeedbackScreen createState() => _IssueFeedbackScreen();
}

class _IssueFeedbackScreen extends State<IssueFeedbackScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedIssue = '系統錯誤'; // 默認問題項目

  final List<String> _issueItems = [
    '系統錯誤',
    '功能建議',
    '使用體驗問題',
    '其他',
  ];

  void _clearForm() {
    setState(() {
      _selectedIssue = '系統錯誤';
      _descriptionController.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('問題回饋表'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '問題項目',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedIssue,
                items: _issueItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIssue = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '選擇問題項目',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '問題敘述',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '請手寫問題敘述',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final description = _descriptionController.text.trim();
                      if (description.isEmpty) {
                        _showSnackBar('請輸入問題敘述！');
                        return;
                      }
                      _showSnackBar('感謝您的反饋！');
                    },
                    child: Text('提交'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _clearForm,
                    child: Text('清除'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
