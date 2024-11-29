import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/usage_data_viewmodel.dart';
import 'package:intl/intl.dart';

class UsageDataScreen extends StatefulWidget {
  @override
  _UsageDataScreenState createState() => _UsageDataScreenState();
}

class _UsageDataScreenState extends State<UsageDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usageDataViewModel =
          Provider.of<UsageDataViewModel>(context, listen: false);
      usageDataViewModel.fetchUsageData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsageDataViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('使用數據'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '數據篩選',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: viewModel.selectedMeterType,
                  items: viewModel.meterTypes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) viewModel.setSelectedMeterType(value);
                  },
                  decoration: InputDecoration(
                    labelText: '選擇表類型',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: viewModel.selectedUnit,
                  items: viewModel.units.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) viewModel.setSelectedUnit(value);
                  },
                  decoration: InputDecoration(
                    labelText: '選擇單位',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => viewModel.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '篩選日期: ${viewModel.formatDate(viewModel.selectedDate)} (${viewModel.selectedUnit})',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  '數據結果',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.usageData.isEmpty
                      ? const Center(
                    child: Text(
                      '未找到相關數據',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 數據結果列表
                      Expanded(
                        child: ListView.separated(
                          itemCount: viewModel.usageData.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = viewModel.usageData[index];
                            return ListTile(
                              title: Text(
                                  '讀數: ${item['recognized_text']} ${viewModel.unitLabel}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('時間: ${viewModel.formatCapturedTime(item['captured_time'])}'),
                                  Text('表類型: ${viewModel.selectedMeterType}'),
                                  if (index > 0)
                                    Text(
                                      '用量 : ${(int.parse(item['recognized_text']) - int.parse(viewModel.usageData[index - 1]['recognized_text'])).abs()} ${viewModel.unitLabel}',
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}
