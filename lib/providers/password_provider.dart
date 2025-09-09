import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import '../models/password_item.dart';
import '../repository/password_repository.dart';
import '../utils/encryption_helper.dart';
import '../utils/settings_helper.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class PasswordProvider with ChangeNotifier {
  final PasswordRepository _repository = PasswordRepository();
  final EncryptionHelper _encryptionHelper = EncryptionHelper();
  final SettingsHelper _settingsHelper = SettingsHelper();

  List<PasswordItem> _passwordItems = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isAuthenticated = false;
  Timer? _autoLockTimer;
  int _autoLockTime = 300; // 默认5分钟
  bool _isAutoLockEnabled = true;

  List<PasswordItem> get passwordItems => _passwordItems;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  // 初始化数据
  Future<void> initialize() async {
    // 初始化sqflite_common_ffi
    sqflite_ffi.sqfliteFfiInit();
    // 设置数据库工厂
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;

    // 初始化设置
    await _settingsHelper.initialize();
    _autoLockTime = await _settingsHelper.getAutoLockTime();
    _isAutoLockEnabled = await _settingsHelper.isAutoLockEnabled();

    final hasMasterPassword = await _encryptionHelper.hasMasterPassword();
    if (!hasMasterPassword) {
      // 如果没有设置主密码，不需要验证
      _isAuthenticated = true;
      await loadPasswordItems();
    } else {
      // 启动自动锁定计时器
      _startAutoLockTimer();
    }
    notifyListeners();
  }

  // 重置自动锁定计时器
  void resetAutoLockTimer() {
    if (!_isAutoLockEnabled || !_isAuthenticated) return;

    _cancelAutoLockTimer();
    _startAutoLockTimer();
  }

  // 启动自动锁定计时器
  void _startAutoLockTimer() {
    if (!_isAutoLockEnabled || !_isAuthenticated) return;

    _autoLockTimer = Timer(Duration(seconds: _autoLockTime), () {
      if (_isAuthenticated) {
        _isAuthenticated = false;
        notifyListeners();
        print('应用已自动锁定');
      }
    });
  }

  // 取消自动锁定计时器
  void _cancelAutoLockTimer() {
    if (_autoLockTimer != null) {
      _autoLockTimer!.cancel();
      _autoLockTimer = null;
    }
  }

  // 注销
  void logout() {
    _isAuthenticated = false;
    _passwordItems = [];
    _searchQuery = '';
    _cancelAutoLockTimer();
    notifyListeners();
  }

  // 检查是否存在主密码
  Future<bool> hasMasterPassword() async {
    return await _encryptionHelper.hasMasterPassword();
  }

  // 监听设置更改
  void listenToSettingsChanges() {
    // 可以在这里添加设置更改的监听逻辑
    // 例如，使用流或回调来通知设置更改
  }

  // 更新自动锁定设置
  Future<void> updateAutoLockSettings() async {
    _autoLockTime = await _settingsHelper.getAutoLockTime();
    _isAutoLockEnabled = await _settingsHelper.isAutoLockEnabled();
    _cancelAutoLockTimer();
    if (_isAutoLockEnabled && _isAuthenticated) {
      _startAutoLockTimer();
    }
  }

  // 复制内容到剪贴板
  Future<void> copyToClipboard(String text) async {
    await _repository.copyToClipboard(text);
  }

  // 验证主密码
  Future<bool> authenticate(String password) async {
    final isValid = await _encryptionHelper.verifyMasterPassword(password);
    if (isValid) {
      _isAuthenticated = true;
      await loadPasswordItems();
      // 启动自动锁定计时器
      _startAutoLockTimer();
      notifyListeners();
    }
    return isValid;
  }

  // 加载所有密码条目
  Future<void> loadPasswordItems() async {
    if (!_isAuthenticated) {
      print('未认证，不加载密码');
      return;
    }

    // 重置自动锁定计时器
    resetAutoLockTimer();

    print('开始加载密码条目...');
    _isLoading = true;
    notifyListeners();

    try {
      if (_searchQuery.isEmpty) {
        print('加载所有密码条目');
        _passwordItems = await _repository.getAllPasswordItems();
      } else {
        print('搜索密码条目: $_searchQuery');
        _passwordItems = await _repository.searchPasswordItems(_searchQuery);
      }
      print('成功加载 ${_passwordItems.length} 个密码条目');
    } catch (e) {
      print('加载密码条目失败: $e');
      _passwordItems = [];
      // 在实际应用中应该处理错误
    }

    _isLoading = false;
    notifyListeners();
  }

  // 添加新密码条目
  Future<void> addPasswordItem(PasswordItem item) async {
    if (!_isAuthenticated) {
      print('未认证，不添加密码');
      return;
    }

    // 重置自动锁定计时器
    resetAutoLockTimer();

    try {
      print('添加密码条目: ${item.title}');
      await _repository.addPasswordItem(item);
      print('密码条目添加成功');
      await loadPasswordItems();
    } catch (e) {
      print('添加密码条目失败: $e');
      // 在实际应用中应该处理错误
    }
  }

  // 更新密码条目
  Future<void> updatePasswordItem(PasswordItem item) async {
    if (!_isAuthenticated) return;

    try {
      await _repository.updatePasswordItem(item);
      await loadPasswordItems();
    } catch (e) {
      // 在实际应用中应该处理错误
    }
  }

  // 删除密码条目
  Future<void> deletePasswordItem(int id) async {
    if (!_isAuthenticated) return;

    try {
      await _repository.deletePasswordItem(id);
      await loadPasswordItems();
    } catch (e) {
      // 在实际应用中应该处理错误
    }
  }

  // 搜索密码条目
  Future<void> searchPasswordItems(String query) async {
    if (!_isAuthenticated) return;

    _searchQuery = query;
    await loadPasswordItems();
  }

  // 生成强密码
  String generateStrongPassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
  }) {
    return _repository.generateStrongPassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSpecialChars: includeSpecialChars,
    );
  }
}
