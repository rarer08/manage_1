import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/password_item.dart';
import '../repository/password_repository.dart';
import '../utils/encryption_helper.dart';

class ImportExportHelper {
  final PasswordRepository _passwordRepository = PasswordRepository();
  final EncryptionHelper _encryptionHelper = EncryptionHelper();

  // 导出所有密码到JSON文件
  Future<String> exportPasswords() async {
    try {
      // 获取所有密码条目
      final passwordItems = await _passwordRepository.getAllPasswordItems();

      // 转换为JSON格式
      final jsonData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'passwords': passwordItems.map((item) => item.toMap()).toList(),
      };

      // 加密整个JSON数据
      final jsonString = jsonEncode(jsonData);
      final encryptedData = await _encryptionHelper.encrypt(jsonString);

      // 获取文档目录
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/passwords_export.json';

      // 写入文件
      final file = File(filePath);
      await file.writeAsString(encryptedData);

      return filePath;
    } catch (e) {
      throw Exception('导出密码失败: \$e');
    }
  }

  // 从JSON文件导入密码
  Future<int> importPasswords(String filePath) async {
    try {
      // 读取文件内容
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final encryptedData = await file.readAsString();

      // 解密数据
      final decryptedData = await _encryptionHelper.decrypt(encryptedData);

      // 解析JSON
      final jsonData = jsonDecode(decryptedData) as Map<String, dynamic>;

      // 验证版本
      if (jsonData['version'] != '1.0') {
        throw Exception('不支持的导出文件版本');
      }

      // 导入密码条目
      final passwords = jsonData['passwords'] as List<dynamic>;
      int importedCount = 0;

      for (final passwordMap in passwords) {
        try {
          final item = PasswordItem.fromMap(passwordMap as Map<String, dynamic>);
          // 由于ID可能冲突，设置为null让数据库自动生成
          final itemToImport = item.copyWith(id: null);
          await _passwordRepository.addPasswordItem(itemToImport);
          importedCount++;
        } catch (e) {
          // 跳过导入失败的条目
          print('导入单个密码失败: \$e');
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('导入密码失败: \$e');
    }
  }

  // 生成一个示例的导入文件路径
  Future<String> getSampleImportPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/passwords_import.json';
  }
}