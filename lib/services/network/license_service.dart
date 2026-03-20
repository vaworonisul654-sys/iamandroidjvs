
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  static final LicenseService _instance = LicenseService._internal();
  factory LicenseService() => _instance;
  LicenseService._internal();

  static const String _proxyStatusUrl = "http://95.163.236.215:8000/v1/status";
  
  String? _currentKey;
  int _balance = 0;
  bool _isActivated = false;

  String? get currentKey => _currentKey;
  int get balance => _balance;
  bool get isActivated => _isActivated;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentKey = prefs.getString("license_key");
    if (_currentKey != null) {
      await checkStatus(_currentKey!);
    }
  }

  Future<bool> checkStatus(String key) async {
    try {
      final response = await http.get(
        Uri.parse(_proxyStatusUrl),
        headers: {"x-license-key": key},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentKey = key;
        _balance = data["balance"] ?? 0;
        _isActivated = data["status"] == "active";
        
        // Save to prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("license_key", key);
        return true;
      } else {
        _isActivated = false;
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentKey = null;
    _isActivated = false;
    _balance = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("license_key");
  }
}
