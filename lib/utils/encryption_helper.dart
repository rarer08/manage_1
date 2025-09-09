import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionHelper {
  static final EncryptionHelper _instance = EncryptionHelper._internal();
  factory EncryptionHelper() => _instance;

  Encrypter? _encrypter;
  static const String _keyPrefsKey = 'encryption_key';
  bool _isInitialized = false;

  EncryptionHelper._internal() {
    // 构造函数不进行异步初始化
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    String? encryptionKey = prefs.getString(_keyPrefsKey);

    if (encryptionKey == null) {
      // 如果没有保存的密钥，生成一个新的密钥并保存
      final key = Key.fromSecureRandom(32);
      encryptionKey = base64.encode(key.bytes);
      await prefs.setString(_keyPrefsKey, encryptionKey);
    }

    // 创建加密器
    final keyBytes = base64.decode(encryptionKey);
    final key = Key(keyBytes);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _isInitialized = true;
  }

  // 加密数据
  Future<String> encrypt(String plainText) async {
    if (!_isInitialized || _encrypter == null) {
      await _initialize();
    }

    // 为每次加密生成新的IV
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encrypt(plainText, iv: iv);
    // 将IV和密文一起返回，用于解密
    print('加密后的文本: $encrypted');
    return base64.encode(iv.bytes + encrypted.bytes);
  }

  // 解密数据
  Future<String> decrypt(String encryptedText) async {
    if (!_isInitialized || _encrypter == null) {
      await _initialize();
    }

    try {
      final encryptedData = base64.decode(encryptedText);
      // 分离IV和密文
      final iv = IV(encryptedData.sublist(0, 16));
      final encrypted = Encrypted(encryptedData.sublist(16));
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('解密错误: $e');
      // 返回原始文本作为回退
      return encryptedText;
    }
  }

  // 验证主密码（这里使用简单的验证，实际应用中应使用更安全的方法）
  Future<bool> verifyMasterPassword(String inputPassword) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedHash = prefs.getString('master_password_hash');

    // 如果是首次设置主密码
    if (storedHash == null) {
      // 在实际应用中，这里应该使用更安全的哈希算法，如Argon2或bcrypt
      // 这里为了简单起见，使用base64作为示例
      final hash = base64.encode(utf8.encode(inputPassword));
      await prefs.setString('master_password_hash', hash);
      return true;
    }

    // 验证现有密码
    final inputHash = base64.encode(utf8.encode(inputPassword));
    return inputHash == storedHash;
  }

  // 检查是否已设置主密码
  Future<bool> hasMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('master_password_hash');
  }

  // 生成强密码
  String generateStrongPassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
    int minUppercase = 0,
    int minLowercase = 0,
    int minNumbers = 0,
    int minSpecialChars = 0,
  }) {
    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const numberChars = '0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    // 验证参数
    if (minUppercase < 0 ||
        minLowercase < 0 ||
        minNumbers < 0 ||
        minSpecialChars < 0) {
      throw Exception('Minimum character counts cannot be negative');
    }

    final requiredCharsCount =
        minUppercase + minLowercase + minNumbers + minSpecialChars;
    if (requiredCharsCount > length) {
      throw Exception('Total minimum character count exceeds password length');
    }

    // 确保至少选择了一个字符集
    String allChars = '';
    if (includeUppercase) allChars += uppercaseChars;
    if (includeLowercase) allChars += lowercaseChars;
    if (includeNumbers) allChars += numberChars;
    if (includeSpecialChars) allChars += specialChars;

    if (allChars.isEmpty) {
      throw Exception('At least one character set must be selected');
    }

    final random = _getRandom();
    final password = <String>[];

    // 添加最小要求的字符
    if (includeUppercase && minUppercase > 0) {
      password.addAll(
        List.generate(
          minUppercase,
          (index) => uppercaseChars[random.nextInt(uppercaseChars.length)],
        ),
      );
    }

    if (includeLowercase && minLowercase > 0) {
      password.addAll(
        List.generate(
          minLowercase,
          (index) => lowercaseChars[random.nextInt(lowercaseChars.length)],
        ),
      );
    }

    if (includeNumbers && minNumbers > 0) {
      password.addAll(
        List.generate(
          minNumbers,
          (index) => numberChars[random.nextInt(numberChars.length)],
        ),
      );
    }

    if (includeSpecialChars && minSpecialChars > 0) {
      password.addAll(
        List.generate(
          minSpecialChars,
          (index) => specialChars[random.nextInt(specialChars.length)],
        ),
      );
    }

    // 填充剩余字符
    final remainingLength = length - password.length;
    password.addAll(
      List.generate(
        remainingLength,
        (index) => allChars[random.nextInt(allChars.length)],
      ),
    );

    // 打乱密码字符顺序
    password.shuffle(random);

    return password.join();
  }

  // 获取随机数生成器（为了测试可替换性）
  Random _getRandom() {
    return Random.secure();
  }
}
