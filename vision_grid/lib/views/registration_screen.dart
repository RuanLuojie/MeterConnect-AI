import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
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

  @override
  void initState() {
    super.initState();
    final registrationViewModel =
        Provider.of<RegistrationViewModel>(context, listen: false);
    _emailController.text = registrationViewModel.email;
  }

  Future<void> _register() async {
    final registrationViewModel =
        Provider.of<RegistrationViewModel>(context, listen: false);

    if (_idCodeController.text.trim().isEmpty) {
      _showSnackBar('編號代碼為必填字段！');
      return;
    }

    registrationViewModel.setIdCode(_idCodeController.text.trim());
    registrationViewModel.setAddress(_addressController.text.trim());
    registrationViewModel.setPhone(_phoneController.text.trim());

    final result = await registrationViewModel.registerUser();

    if (result['success'] == true) {
      _showSnackBar(result['message']);
      _clearFields();
    } else {
      _showSnackBar(result['message']);
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
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);
    final isLoading = Provider.of<RegistrationViewModel>(context).isLoading;

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
              Consumer<SettingsViewModel>(
                builder: (context, settings, _) {
                  return DropdownButtonFormField<String>(
                    value: settings.meterType,
                    items: [
                      DropdownMenuItem(value: "電表", child: Text("電表")),
                      DropdownMenuItem(value: "瓦斯表", child: Text("瓦斯表")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        settings.setMeterType(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '表類別',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
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
                    onPressed: isLoading ? null : _register,
                    child: isLoading
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
