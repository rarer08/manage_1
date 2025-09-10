import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard/clipboard.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import '../routes/app_routes.dart';

class AddEditPasswordPage extends StatefulWidget {
  final PasswordItem? item;
  final bool isViewOnly;

  const AddEditPasswordPage({super.key, this.item, this.isViewOnly = false});

  @override
  State<AddEditPasswordPage> createState() => _AddEditPasswordPageState();
}

class _AddEditPasswordPageState extends State<AddEditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，填充表单数据
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _usernameController.text = widget.item!.username;
      _passwordController.text = widget.item!.password;
      _websiteController.text = widget.item!.website;
      _notesController.text = widget.item!.notes;
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      print('表单验证失败');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      final now = DateTime.now();

      final passwordItem = PasswordItem(
        id: widget.item?.id,
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        website: _websiteController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      );

      print('准备保存密码: ${passwordItem.title}');

      if (widget.item == null) {
        print('添加新密码');
        await passwordProvider.addPasswordItem(passwordItem);
        print('新密码添加成功');
      } else {
        print('更新现有密码');
        await passwordProvider.updatePasswordItem(passwordItem);
        print('密码更新成功');
      }

      AppRoutes.navigateBack(context);
      // 不需要手动刷新，因为addPasswordItem和updatePasswordItem方法中已经调用了loadPasswordItems()
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generatePassword() {
    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    final password = passwordProvider.generateStrongPassword();
    _passwordController.text = password;
  }

  void _copyToClipboard(String text, String message) {
    FlutterClipboard.copy(text).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewOnly ? '查看密码' : (widget.item == null ? '添加密码' : '编辑密码')),
        leading: widget.isViewOnly ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.navigateBack(context),
        ) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                TextFormField(
                  controller: _titleController,
                  enabled: !widget.isViewOnly,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                  ),
                  validator: widget.isViewOnly ? null : (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入标题';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 用户名
                TextFormField(
                  controller: _usernameController,
                  enabled: !widget.isViewOnly,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(),
                  ),
                  validator: widget.isViewOnly ? null : (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密码
                TextFormField(
                  controller: _passwordController,
                  enabled: !widget.isViewOnly,
                  obscureText: widget.isViewOnly ? false : _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: const OutlineInputBorder(),
                    suffixIcon: widget.isViewOnly ? null : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            if (_passwordController.text.isNotEmpty) {
                              _copyToClipboard(_passwordController.text, '密码已复制到剪贴板');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  validator: widget.isViewOnly ? null : (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                widget.isViewOnly ? Container() : ElevatedButton.icon(
                  onPressed: _generatePassword,
                  icon: const Icon(Icons.key),
                  label: const Text('生成强密码'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),

                // Website
                TextFormField(
                  controller: _websiteController,
                  enabled: !widget.isViewOnly,
                  decoration: InputDecoration(
                    labelText: '网址',
                    border: const OutlineInputBorder(),
                    suffixIcon: widget.isViewOnly ? null : IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (_websiteController.text.isNotEmpty) {
                          _copyToClipboard(_websiteController.text, '网址已复制到剪贴板');
                        }
                      },
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),

                // 备注
                TextFormField(
                  controller: _notesController,
                  enabled: !widget.isViewOnly,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // 保存按钮
                widget.isViewOnly ? Container() : ElevatedButton(
                  onPressed: _isLoading ? null : _savePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(widget.item == null ? '添加' : '保存'),
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
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}