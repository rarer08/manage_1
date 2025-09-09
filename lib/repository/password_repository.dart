import '../database/db_helper.dart';
import '../models/password_item.dart';
import '../utils/encryption_helper.dart';
import '../utils/import_export_helper.dart';

class PasswordRepository {
  final DBHelper _dbHelper = DBHelper.instance;
  final EncryptionHelper _encryptionHelper = EncryptionHelper();

  // 添加新的密码条目
  Future<int> addPasswordItem(PasswordItem item) async {
    // 加密密码
    final encryptedPassword = await _encryptionHelper.encrypt(item.password);
    // 创建包含加密密码的新条目
    final encryptedItem = item.copyWith(password: encryptedPassword);
    // 插入数据库
    return await _dbHelper.insert(encryptedItem);
  }

  // 获取所有密码条目（带解密）
  Future<List<PasswordItem>> getAllPasswordItems() async {
    final items = await _dbHelper.queryAllRows();
    // 解密每个条目的密码
    return Future.wait(items.map((item) async {
      final decryptedPassword = await _encryptionHelper.decrypt(item.password);
      return item.copyWith(password: decryptedPassword);
    }).toList());
  }

  // 获取单个密码条目（带解密）
  Future<PasswordItem?> getPasswordItemById(int id) async {
    final item = await _dbHelper.queryRow(id);
    if (item != null) {
      // 解密密码
      final decryptedPassword = await _encryptionHelper.decrypt(item.password);
      return item.copyWith(password: decryptedPassword);
    }
    return null;
  }

  // 更新密码条目
  Future<int> updatePasswordItem(PasswordItem item) async {
    // 加密新密码
    final encryptedPassword = await _encryptionHelper.encrypt(item.password);
    // 创建包含加密密码的更新条目
    final encryptedItem = item.copyWith(password: encryptedPassword);
    // 更新数据库
    return await _dbHelper.update(encryptedItem);
  }

  // 删除密码条目
  Future<int> deletePasswordItem(int id) async {
    return await _dbHelper.delete(id);
  }

  // 搜索密码条目（带解密）
  Future<List<PasswordItem>> searchPasswordItems(String query) async {
    final items = await _dbHelper.search(query);
    // 解密每个条目的密码
    return Future.wait(items.map((item) async {
      final decryptedPassword = await _encryptionHelper.decrypt(item.password);
      return item.copyWith(password: decryptedPassword);
    }).toList());
  }

  // 生成强密码
  String generateStrongPassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
  }) {
    return _encryptionHelper.generateStrongPassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSpecialChars: includeSpecialChars,
    );
  }

  // 复制内容到剪贴板
  Future<void> copyToClipboard(String text) async {
    // 实际应用中可能需要使用剪贴板插件
    // 这里只是一个示例实现
    // 在实际应用中，应该使用日志库记录，而不是print
    // logger.info('密码已复制到剪贴板');
  }

  // 导出所有密码
  Future<String> exportAllPasswords() async {
    final importExportHelper = ImportExportHelper();
    return await importExportHelper.exportPasswords();
  }

  // 从文件导入密码
  Future<int> importPasswordsFromFile(String filePath) async {
    final importExportHelper = ImportExportHelper();
    return await importExportHelper.importPasswords(filePath);
  }

  // 获取示例导入文件路径
  Future<String> getSampleImportFilePath() async {
    final importExportHelper = ImportExportHelper();
    return await importExportHelper.getSampleImportPath();
  }
}