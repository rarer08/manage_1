import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/password_list_page.dart';
import 'providers/password_provider.dart';

void main() {
  runApp(
    // 使用Provider提供状态管理
    ChangeNotifierProvider(
      create: (context) => PasswordProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '密码管理器',
      theme: ThemeData(
        // 设置应用主题
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 设置初始页面为密码列表页
      home: const PasswordListPage(),
      // 禁用调试标志
      debugShowCheckedModeBanner: false,
    );
  }
}
