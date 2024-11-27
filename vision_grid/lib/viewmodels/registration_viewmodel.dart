import 'package:flutter/material.dart';
import '../models/registration_service.dart';
import '../viewmodels/settings_viewmodel.dart';

class RegistrationViewModel with ChangeNotifier {
  final SettingsViewModel _settingsViewModel;
  bool _isLoading = false;

  RegistrationViewModel(this._settingsViewModel);

  bool get isLoading => _isLoading;

  String get email => _settingsViewModel.email;

  void setIdCode(String idCode) {
    _settingsViewModel.setIdCode(idCode);
  }

  void setAddress(String address) {
    _settingsViewModel.setAddress(address);
  }

  void setPhone(String phone) {
    _settingsViewModel.setPhone(phone);
  }

  void setMeterType(String meterType) {
    _settingsViewModel.setMeterType(meterType);
  }

  Future<Map<String, dynamic>> registerUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await RegistrationService().registerUser(_settingsViewModel);

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
