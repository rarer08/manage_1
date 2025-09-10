import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import '../routes/app_routes.dart';
import 'auth_page.dart';
import 'add_edit_password_page.dart';
import '../utils/clipboard_helper.dart';

class PasswordListCompactPage extends StatefulWidget {
  const PasswordListCompactPage({super.key});

  @override
  State<PasswordListCompactPage> createState() =>
      _PasswordListCompactPageState();
}

class _PasswordListCompactPageState extends State<PasswordListCompactPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化密码提供者
    final passwordProvider = Provider.of<PasswordProvider>(
      context,
      listen: false,
    );
    passwordProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final passwordProvider = Provider.of<PasswordProvider>(context);

    // 检查认证状态
    if (!passwordProvider.isAuthenticated) {
      return const AuthPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('密码管理器 (简洁版)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.passwordList);
            },
            tooltip: '切换到详细视图',
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              passwordProvider.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '搜索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                passwordProvider.searchPasswordItems(value);
              },
            ),
          ),
          // 密码列表
          Expanded(
            child: passwordProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : passwordProvider.passwordItems.isEmpty
                ? const Center(child: Text('没有找到密码条目'))
                : ListView.builder(
                    itemCount: passwordProvider.passwordItems.length,
                    itemBuilder: (context, index) {
                      final item = passwordProvider.passwordItems[index];
                      return PasswordItemCompactTile(
                        item: item,
                        onTap: () => _navigateToDetailPage(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateToAddEditPassword(context);
        },
        child: const Icon(Icons.add),
        tooltip: '添加密码',
      ),
    );
  }

  void _navigateToDetailPage(PasswordItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPasswordPage(item: item, isViewOnly: true),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// 简洁版密码条目瓦片组件
class PasswordItemCompactTile extends StatelessWidget {
  final PasswordItem item;
  final VoidCallback onTap;

  const PasswordItemCompactTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  // 该方法已迁移到ClipboardHelper工具类中

  // 根据item的id生成不同的背景颜色
  Color _getBackgroundColor() {
    final int hash = item.id.hashCode;
    // 使用模运算获取0-7之间的数值
    final int colorIndex = hash % 8;
    // 定义一组柔和的背景颜色
    const List<Color> colors = [
      Color(0xFFF5F7FA), // 浅灰
      Color(0xFFE8F5E9), // 浅绿
      Color(0xFFE3F2FD), // 浅蓝
      Color(0xFFFBE9E7), // 浅红
      Color(0xFFFFF8E1), // 浅黄
      Color(0xFFEDE7F6), // 浅紫
      Color(0xFFE0F7FA), // 浅青
      Color(0xFFFFF3E0), // 浅橙
    ];
    return colors[colorIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _getBackgroundColor(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        onTap: onTap,
        leading: const Icon(Icons.public, color: Colors.blue),
        title: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          ClipboardHelper.copyToClipboard(context, item.username, '用户名'),
                      child: Tooltip(
                        message: '点击复制',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.transparent,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            item.username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // const Icon(Icons.lock, size: 14, color: Colors.grey),
                  // const SizedBox(width: 8),
                  // Expanded(
                  //   child: Text(
                  //     item.password.isNotEmpty ? item.password : '未设置',
                  //     overflow: TextOverflow.ellipsis,
                  //     style: const TextStyle(fontSize: 12),
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  const Icon(Icons.link, size: 14, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => ClipboardHelper.copyToClipboard(
                        context,
                        item.website.isNotEmpty ? item.website : '',
                        '网站',
                      ),
                      child: Tooltip(
                        message: '点击复制',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.transparent,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            item.website.isNotEmpty ? item.website : '未设置',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(color: Colors.grey[300]), // 空容器，占比更大
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
