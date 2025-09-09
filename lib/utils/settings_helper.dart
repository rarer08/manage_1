import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  static final SettingsHelper _instance = SettingsHelper._internal();
  factory SettingsHelper() => _instance;

  static const String _autoLockTimeKey = 'auto_lock_time';
  static const String _isAutoLockEnabledKey = 'is_auto_lock_enabled';
  static const int _defaultAutoLockTime = 300; // 默认5分钟(300秒)

  SettingsHelper._internal();

  // 初始化设置
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_autoLockTimeKey)) {
      await prefs.setInt(_autoLockTimeKey, _defaultAutoLockTime);
    }
    if (!prefs.containsKey(_isAutoLockEnabledKey)) {
      await prefs.setBool(_isAutoLockEnabledKey, true);
    }
  }

  // 获取自动锁定时间(秒)
  Future<int> getAutoLockTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockTimeKey) ?? _defaultAutoLockTime;
  }

  // 设置自动锁定时间(秒)
  Future<void> setAutoLockTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeKey, seconds);
  }

  // 获取自动锁定是否启用
  Future<bool> isAutoLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAutoLockEnabledKey) ?? true;
  }

  // 设置自动锁定是否启用
  Future<void> setAutoLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAutoLockEnabledKey, enabled);
  }

  // 检查主密码是否存在
  Future<bool> hasMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('master_password_hash');
  }

  // 修改主密码
  Future<bool> changeMasterPassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedHash = prefs.getString('master_password_hash');

    // 验证旧密码
    if (storedHash != null) {
      final inputHash = _hashPassword(oldPassword);
      if (inputHash != storedHash) {
        return false; // 旧密码验证失败
      }
    }

    // 设置新密码
    final newHash = _hashPassword(newPassword);
    await prefs.setString('master_password_hash', newHash);
    return true;
  }

  // 简单的密码哈希方法（实际应用中应使用更安全的哈希算法）
  String _hashPassword(String password) {
    // 在实际应用中，这里应该使用更安全的哈希算法，如Argon2或bcrypt
    // 这里为了简单起见，使用base64作为示例
    return base64.encode(utf8.encode(password));
  }
}