import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  // 默认密码长度
  int _passwordLength = 16;
  // 密码选项
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;
  // 生成的密码
  String _generatedPassword = '';

  // 生成密码
  void _generatePassword() {
    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    setState(() {
      _generatedPassword = passwordProvider.generateStrongPassword(
        length: _passwordLength,
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeNumbers: _includeNumbers,
        includeSpecialChars: _includeSpecialChars,
      );
    });
  }

  // 复制密码到剪贴板
  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      passwordProvider.copyToClipboard(_generatedPassword).then((_) {
        // 显示复制成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码已复制到剪贴板')),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化时生成一个密码
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('密码生成器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 生成的密码展示区域
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
                color: Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _generatedPassword,
                      style: const TextStyle(fontSize: 18, fontFamily: 'Courier'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                    tooltip: '复制密码',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 密码长度选择
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                  [
                    const Text('密码长度:'),
                    Text('$_passwordLength'),
                  ],
                ),
                Slider(
                  value: _passwordLength.toDouble(),
                  min: 8,
                  max: 32,
                  divisions: 24,
                  onChanged: (value) {
                    setState(() {
                      _passwordLength = value.toInt();
                    });
                  },
                  onChangeEnd: (_) => _generatePassword(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 密码选项
            Column(
              children: [
                CheckboxListTile(
                  title: const Text('包含大写字母 (A-Z)'),
                  value: _includeUppercase,
                  onChanged: (bool? value) {
                    setState(() {
                      _includeUppercase = value ?? true;
                      _generatePassword();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('包含小写字母 (a-z)'),
                  value: _includeLowercase,
                  onChanged: (bool? value) {
                    setState(() {
                      _includeLowercase = value ?? true;
                      _generatePassword();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('包含数字 (0-9)'),
                  value: _includeNumbers,
                  onChanged: (bool? value) {
                    setState(() {
                      _includeNumbers = value ?? true;
                      _generatePassword();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('包含特殊字符 (!@#\$%)'),
                  value: _includeSpecialChars,
                  onChanged: (bool? value) {
                    setState(() {
                      _includeSpecialChars = value ?? true;
                      _generatePassword();
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            // 重新生成按钮
            ElevatedButton(
              onPressed: _generatePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('重新生成密码'),
            ),
          ],
        ),
      ),
    );
  }
}