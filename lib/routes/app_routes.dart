import 'package:flutter/material.dart';
import '../pages/auth_page.dart';
import '../pages/password_list_page.dart';
import '../pages/password_list_compact_page.dart';
import '../pages/password_generator_page.dart';
import '../pages/add_edit_password_page.dart';
import '../pages/import_export_page.dart';
import '../pages/settings_page.dart';
import '../models/password_item.dart';

class AppRoutes {
  // 定义路由名称
  static const String auth = '/auth';
  static const String passwordList = '/password_list';
  static const String passwordListCompact = '/password_list_compact';
  static const String addEditPassword = '/add_edit_password';
  static const String passwordGenerator = '/password_generator';
  static const String importExport = '/import_export';
  static const String settings = '/settings';

  // 创建路由表
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      passwordList: (context) => const PasswordListPage(),
      passwordListCompact: (context) => const PasswordListCompactPage(),
      addEditPassword: (context) => const AddEditPasswordPage(),
      auth: (context) => const AuthPage(),
      passwordGenerator: (context) => const PasswordGeneratorPage(),
      importExport: (context) => const ImportExportPage(),
      settings: (context) => const SettingsPage(),
    };
  }

  // 导航到添加/编辑密码页面
  static void navigateToAddEditPassword(BuildContext context, {PasswordItem? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPasswordPage(item: item),
      ),
    );
  }

  // 导航到简洁版密码列表页面
  static void navigateToPasswordListCompact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordListCompactPage(),
      ),
    );
  }

  // 导航到密码生成器页面
  static void navigateToPasswordGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordGeneratorPage(),
      ),
    );
  }

  // 导航到认证页面
  static void navigateToAuth(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  // 返回上一页
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  // 导航到导入导出页面
  static void navigateToImportExport(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const ImportExportPage(),
      ),
    );
  }

  // 导航到设置页面
  static void navigateToSettings(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }
}