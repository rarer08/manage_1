import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isNewUser = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 检查是否是新用户（没有设置主密码）
    _checkIfNewUser();
  }

  Future<void> _checkIfNewUser() async {
    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    final hasMasterPassword = await passwordProvider.hasMasterPassword();
    setState(() {
      _isNewUser = !hasMasterPassword;
    });
  }

  Future<void> _authenticate() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = '密码不能为空';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      final success = await passwordProvider.authenticate(password);
      if (!success && mounted) {
        setState(() {
          _errorMessage = '密码错误';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '认证失败，请重试';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 应用图标和标题
                const Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  _isNewUser ? '设置主密码' : '请输入主密码',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isNewUser 
                    ? '为您的密码管理器设置一个安全的主密码' 
                    : '输入您的主密码以访问您的密码库',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // 密码输入框
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '主密码',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                  onSubmitted: (_) => _authenticate(),
                ),
                const SizedBox(height: 20),

                // 认证按钮
                ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(_isNewUser ? '设置密码' : '解锁'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}