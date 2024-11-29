import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/usage_data_service.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';

class UsageDataViewModel with ChangeNotifier {
  String _selectedMeterType = '電表';
  String _selectedUnit = '日';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _usageData = [];
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = false;

  final List<String> meterTypes = ['電表', '瓦斯表'];
  final List<String> units = ['日', '週', '月', '年'];

  final UsageDataService _usageDataService = UsageDataService();

  String get selectedMeterType => _selectedMeterType;
  String get selectedUnit => _selectedUnit;
  DateTime get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get usageData => _usageData;
  bool get isLoading => _isLoading;

  String get unitLabel => _selectedMeterType == '電表' ? 'kWh' : 'm³';

  String formatDate(DateTime date) {
    switch (_selectedUnit) {
      case '日':
        return DateFormat('yyyy/MM/dd', 'zh_TW').format(date);
      case '週':
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return "${DateFormat('yyyy/MM/dd', 'zh_TW').format(startOfWeek)} - ${DateFormat('yyyy/MM/dd', 'zh_TW').format(endOfWeek)}";
      case '月':
        return DateFormat('yyyy/MM', 'zh_TW').format(date);
      case '年':
        return DateFormat('yyyy', 'zh_TW').format(date);
      default:
        return DateFormat('yyyy/MM/dd', 'zh_TW').format(date);
    }
  }

  String formatCapturedTime(String capturedTime) {
    try {
      final DateTime parsedTime = DateTime.parse(capturedTime);
      return DateFormat('yyyy/MM/dd-HH:mm', 'zh_TW').format(parsedTime); // 自定義格式
    } catch (e) {
      print('時間格式化失敗: $e');
      return capturedTime; // 格式化失敗時回傳原始時間字串
    }
  }

  void setSelectedMeterType(String value) {
    _selectedMeterType = value;
    _filterData();
  }

  void setSelectedUnit(String value) {
    _selectedUnit = value;
    _filterData();
  }

  void _filterData() {
    final selectedType = _selectedMeterType == '電表' ? 'electric' : 'gas';

    _usageData = _allData.where((item) {
      final matchesType = item['meter_type']?.toLowerCase() == selectedType;

      final itemDate = DateTime.tryParse(item['captured_time']);
      if (itemDate == null) return false;

      final matchesDate = _matchesDate(itemDate);

      return matchesType && matchesDate;
    }).toList();

    notifyListeners();
  }

  bool _matchesDate(DateTime itemDate) {
    switch (_selectedUnit) {
      case '日':
        return _isSameDay(itemDate, _selectedDate);
      case '週':
        return _isSameWeek(itemDate, _selectedDate);
      case '月':
        return _isSameMonth(itemDate, _selectedDate);
      case '年':
        return _isSameYear(itemDate, _selectedDate);
      default:
        return false;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isSameWeek(DateTime date, DateTime referenceDate) {
    final referenceStartOfWeek =
        referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    final referenceEndOfWeek = referenceStartOfWeek.add(Duration(days: 6));
    return date.isAfter(
            referenceStartOfWeek.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(referenceEndOfWeek.add(const Duration(milliseconds: 1)));
  }

  bool _isSameMonth(DateTime date, DateTime referenceDate) {
    return date.year == referenceDate.year && date.month == referenceDate.month;
  }

  bool _isSameYear(DateTime date, DateTime referenceDate) {
    return date.year == referenceDate.year;
  }

  Future<void> fetchUsageData(BuildContext context) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

    if (settings.apiKey.isEmpty) {
      print("API Key 未設置");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _allData = await _usageDataService.fetchUsageData(settings.apiKey);

      print("加載的所有數據: $_allData");

      _filterData();
    } catch (e) {
      print("加載數據失敗: $e");
      _allData = [];
      _usageData = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate;

    if (_selectedUnit == '日') {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
    } else if (_selectedUnit == '月') {
      pickedDate = await showMonthPicker(context, _selectedDate);
    } else if (_selectedUnit == '年') {
      pickedDate = await showYearPicker(context, _selectedDate);
    }

    if (pickedDate != null) {
      _selectedDate = pickedDate;
      notifyListeners();
      _filterData();
    }
  }

  Future<DateTime?> showYearPicker(
      BuildContext context, DateTime initialDate) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = initialDate.year;

        return AlertDialog(
          title: Text("選擇年份"),
          content: SizedBox(
            height: 200,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final year = 2020 + index;
                  if (year > 2030) return null;
                  return Center(
                    child: Text('$year'),
                  );
                },
              ),
              onSelectedItemChanged: (index) {
                tempYear = 2020 + index;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(DateTime(tempYear));
              },
              child: Text("確認"),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> showMonthPicker(
      BuildContext context, DateTime initialDate) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;

        return AlertDialog(
          title: Text("選擇月份"),
          content: SizedBox(
            height: 200,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= 12) return null;
                  final month = DateTime(initialDate.year, index + 1, 1);
                  return Center(
                    child: Text(DateFormat('MMMM', 'zh_TW').format(month)),
                  );
                },
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
}
