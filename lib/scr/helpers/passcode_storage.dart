import 'package:shared_preferences/shared_preferences.dart';

class PasscodeStorage {
  static const String _enabledKey = 'passcode_enabled';
  static const String _codeKey = 'passcode_value';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<bool> isEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<String?> getPasscode() async {
    final prefs = await _prefs();
    return prefs.getString(_codeKey);
  }

  static Future<void> setPasscode(String passcode) async {
    final prefs = await _prefs();
    await prefs.setString(_codeKey, passcode);
    await prefs.setBool(_enabledKey, true);
  }

  static Future<void> disablePasscode() async {
    final prefs = await _prefs();
    await prefs.setBool(_enabledKey, false);
    await prefs.remove(_codeKey);
  }
}
