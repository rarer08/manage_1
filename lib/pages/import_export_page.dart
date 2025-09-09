import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import '../repository/password_repository.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  final PasswordRepository _passwordRepository = PasswordRepository();
  String _statusMessage = '';
  bool _isLoading = false;
  String _filePath = '';

  // 导出密码
  Future<void> _exportPasswords() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导出密码...';
    });

    try {
      final filePath = await _passwordRepository.exportAllPasswords();
      setState(() {
        _isLoading = false;
        _statusMessage = '导出成功！';
        _filePath = filePath;
      });

      // 显示成功对话框
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('密码已导出到: \$filePath')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '导出失败: \$e';
      });
    }
  }

  // 导入密码
  Future<void> _importPasswords() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导入密码...';
    });

    try {
      // 在实际应用中，这里应该打开文件选择器让用户选择文件
      // 这里使用示例路径
      final filePath = await _passwordRepository.getSampleImportFilePath();

      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导入文件不存在，请先导出密码或选择正确的文件';
        });
        return;
      }

      final importedCount = await _passwordRepository.importPasswordsFromFile(filePath);

      // 刷新密码列表
      Provider.of<PasswordProvider>(context, listen: false).loadPasswordItems();

      setState(() {
        _isLoading = false;
        _statusMessage = '导入成功！共导入 $importedCount 条密码';
        _filePath = filePath;
      });

      // 显示成功对话框
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 $importedCount 条密码')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '导入失败: \$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入导出密码'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _exportPasswords,
              child: const Text('导出所有密码'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _importPasswords,
              child: const Text('导入密码'),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains('成功') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            if (_filePath.isNotEmpty)
              Text('文件路径: $_filePath'),
          ],
        ),
      ),
    );
  }
}