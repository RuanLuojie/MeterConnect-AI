import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsageDataScreen extends StatefulWidget {
  @override
  _UsageDataScreenState createState() => _UsageDataScreenState();
}

class _UsageDataScreenState extends State<UsageDataScreen> {
  String _selectedMeterType = '電表';
  String _selectedUnit = '日';
  DateTime _selectedDate = DateTime.now();

  final List<String> _meterTypes = ['電表', '瓦斯表'];
  final List<String> _units = ['日', '週', '月'];

  String _formatDate(DateTime date) {
    switch (_selectedUnit) {
      case '日':
        return DateFormat('yyyy/MM/dd', 'zh_TW').format(date);
      case '週':
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${DateFormat('yyyy/MM/dd', 'zh_TW').format(startOfWeek)} - ${DateFormat('yyyy/MM/dd', 'zh_TW').format(endOfWeek)}';
      case '月':
        return DateFormat('yyyy/MM', 'zh_TW').format(date);
      default:
        return DateFormat('yyyy/MM/dd', 'zh_TW').format(date);
    }
  }

  Future<void> _pickDate() async {
    if (_selectedUnit == '日') {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    } else if (_selectedUnit == '月') {
      final pickedMonth = await showMonthPicker(context, _selectedDate);
      if (pickedMonth != null) {
        setState(() {
          _selectedDate = pickedMonth;
        });
      }
    }
  }

  Future<DateTime?> showMonthPicker(BuildContext context, DateTime initialDate) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;

        return AlertDialog(
          title: Text("選擇月份"),
          content: SizedBox(
            height: 200,
            child: ListWheelScrollView(
              itemExtent: 50,
              children: List.generate(
                12,
                    (index) => Center(
                  child: Text(
                    DateFormat('MMMM', 'zh_TW').format(DateTime(2020, index + 1)),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                tempDate = DateTime(initialDate.year, index + 1, 1);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(tempDate);
              },
              child: Text("確認"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用數據'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '數據篩選',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMeterType,
              items: _meterTypes.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMeterType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: '選擇表類型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: _units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
              },
              decoration: InputDecoration(
                labelText: '選擇單位',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '選擇日期: ${_formatDate(_selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '數據結果',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('數據項目 ${index + 1}'),
                    subtitle: Text('數據內容 ${index * 100} kWh/m³'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
