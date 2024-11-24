import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/registration_service.dart';
import '../views/camera_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _idCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedMeterType = "電表";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    _emailController.text = settingsViewModel.email;
  }

  Future<void> _register() async {
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);

    if (_idCodeController.text.trim().isEmpty) {
      _showSnackBar('編號代碼為必填字段！');
      return;
    }

    settingsViewModel.setIdCode(_idCodeController.text.trim());
    settingsViewModel.setAddress(_addressController.text.trim());
    settingsViewModel.setPhone(_phoneController.text.trim());
    settingsViewModel.setMeterType(_selectedMeterType);

    setState(() => _isLoading = true);
    final success = await RegistrationService().registerUser(settingsViewModel);
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('註冊成功！');
      _clearFields();
    } else {
      _showSnackBar('註冊失敗，請稍後重試。');
    }
  }

  Future<void> _captureIdCode() async {
    String? recognizedText = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          displayPromptText: '請將方框對準編號代碼',
        ),
      ),
    );

    if (recognizedText != null && recognizedText.isNotEmpty) {
      setState(() {
        _idCodeController.text = recognizedText;
      });
    } else {
      _showSnackBar('未能識別編號代碼，請重試。');
    }
  }

  void _clearFields() {
    setState(() {
      _idCodeController.clear();
      _addressController.clear();
      _phoneController.clear();
      _selectedMeterType = "電表";
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('註冊')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _idCodeController,
                decoration: InputDecoration(
                  labelText: '編號代碼',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _captureIdCode,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMeterType,
                items: [
                  DropdownMenuItem(value: "電表", child: Text("電表")),
                  DropdownMenuItem(value: "瓦斯表", child: Text("瓦斯表")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMeterType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '表類別',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '電子郵箱',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '地址',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '電話',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('註冊'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text('清除'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
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
