import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import '../utils/settings_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsHelper _settingsHelper = SettingsHelper();
  int _autoLockTime = 300; // 默认5分钟
  bool _isAutoLockEnabled = true;
  bool _isLoading = true;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _passwordChangeMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsHelper.initialize();
    final autoLockTime = await _settingsHelper.getAutoLockTime();
    final isAutoLockEnabled = await _settingsHelper.isAutoLockEnabled();

    setState(() {
      _autoLockTime = autoLockTime;
      _isAutoLockEnabled = isAutoLockEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveAutoLockSettings() async {
    await _settingsHelper.setAutoLockTime(_autoLockTime);
    await _settingsHelper.setAutoLockEnabled(_isAutoLockEnabled);
    // 通知PasswordProvider更新自动锁定设置
    Provider.of<PasswordProvider>(context, listen: false).updateAutoLockSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自动锁定设置已保存')),
    );
  }

  Future<void> _changeMasterPassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordChangeMessage = '新密码和确认密码不匹配';
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _passwordChangeMessage = '密码长度至少为8个字符';
      });
      return;
    }

    final result = await _settingsHelper.changeMasterPassword(oldPassword, newPassword);
    if (result) {
      setState(() {
        _passwordChangeMessage = '主密码修改成功';
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      // 重新认证用户
      Provider.of<PasswordProvider>(context, listen: false).authenticate(newPassword);
    } else {
      setState(() {
        _passwordChangeMessage = '旧密码验证失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '自动锁定设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('启用自动锁定'),
              value: _isAutoLockEnabled,
              onChanged: (value) {
                setState(() {
                  _isAutoLockEnabled = value;
                });
                _saveAutoLockSettings();
              },
            ),
            if (_isAutoLockEnabled)
              ListTile(
                title: const Text('自动锁定时间'),
                subtitle: Text('${_autoLockTime ~/ 60} 分钟'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showAutoLockTimePicker(),
              ),
            const SizedBox(height: 30),
            const Text(
              '主密码设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: '旧密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            if (_passwordChangeMessage.isNotEmpty)
              Text(
                _passwordChangeMessage,
                style: TextStyle(
                  color: _passwordChangeMessage.contains('成功') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changeMasterPassword,
              child: const Text('修改主密码'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockTimePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择自动锁定时间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('1分钟'),
                leading: Radio<int>(
                  value: 60,
                  groupValue: _autoLockTime,
                  onChanged: (value) {
                    setState(() {
                      _autoLockTime = value!;
                    });
                    Navigator.pop(context);
                    _saveAutoLockSettings();
                  },
                ),
              ),
              ListTile(
                title: const Text('5分钟'),
                leading: Radio<int>(
                  value: 300,
                  groupValue: _autoLockTime,
                  onChanged: (value) {
                    setState(() {
                      _autoLockTime = value!;
                    });
                    Navigator.pop(context);
                    _saveAutoLockSettings();
                  },
                ),
              ),
              ListTile(
                title: const Text('10分钟'),
                leading: Radio<int>(
                  value: 600,
                  groupValue: _autoLockTime,
                  onChanged: (value) {
                    setState(() {
                      _autoLockTime = value!;
                    });
                    Navigator.pop(context);
                    _saveAutoLockSettings();
                  },
                ),
              ),
              ListTile(
                title: const Text('30分钟'),
                leading: Radio<int>(
                  value: 1800,
                  groupValue: _autoLockTime,
                  onChanged: (value) {
                    setState(() {
                      _autoLockTime = value!;
                    });
                    Navigator.pop(context);
                    _saveAutoLockSettings();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}