import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import '../routes/app_routes.dart';
import 'auth_page.dart';
import 'add_edit_password_page.dart';
import '../utils/url_launcher_helper.dart';
import '../utils/clipboard_helper.dart';

class PasswordListPage extends StatefulWidget {
  const PasswordListPage({super.key});

  @override
  State<PasswordListPage> createState() => _PasswordListPageState();
}

class _PasswordListPageState extends State<PasswordListPage> {
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
        title: const Text('密码管理器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              AppRoutes.navigateToPasswordListCompact(context);
            },
            tooltip: '切换到简洁视图',
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              passwordProvider.logout();
            },
          ),
          const SizedBox(width: 16),
          // 密码生成器入口
          IconButton(
            icon: const Icon(Icons.password),
            onPressed: () {
              AppRoutes.navigateToPasswordGenerator(context);
            },
            tooltip: '密码生成器',
          ),
          const SizedBox(width: 16),
          // 导入导出入口
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              AppRoutes.navigateToImportExport(context);
            },
            tooltip: '导入导出',
          ),
          const SizedBox(width: 16),
          // 设置入口
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRoutes.navigateToSettings(context);
            },
            tooltip: '设置',
          ),
          const SizedBox(width: 16),
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
                      return PasswordItemTile(
                        item: item,
                        onEdit: () => _navigateToEditPage(item),
                        onDelete: () => _deletePasswordItem(item.id!),
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

  void _navigateToEditPage(PasswordItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditPasswordPage(item: item)),
    ).then(
      (_) => Provider.of<PasswordProvider>(
        context,
        listen: false,
      ).loadPasswordItems(),
    );
  }

  void _deletePasswordItem(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个密码条目吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<PasswordProvider>(
                context,
                listen: false,
              ).deletePasswordItem(id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// 密码条目瓦片组件
class PasswordItemTile extends StatefulWidget {
  final PasswordItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PasswordItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PasswordItemTile> createState() => _PasswordItemTileState();
}

class _PasswordItemTileState extends State<PasswordItemTile> {
  bool _obscurePassword = true;

  // 根据item的id生成不同的背景颜色
  Color _getBackgroundColor() {
    final int hash = widget.item.id.hashCode;
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

  // 该方法已迁移到ClipboardHelper工具类中

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: _getBackgroundColor(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.public, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: widget.onEdit,
                      tooltip: '编辑',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: widget.onDelete,
                      color: Colors.red,
                      tooltip: '删除',
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            // 两列布局
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左列 - 用户名和密码
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户名
                      _buildCredentialField(
                        label: '用户名',
                        value: widget.item.username,
                        icon: Icons.person,
                        onCopy: () =>
                            ClipboardHelper.copyToClipboard(context, widget.item.username, '用户名'),
                      ),
                      const SizedBox(height: 12),
                      // 密码
                      // 根据_obscurePassword的值决定显示的内容
                      _buildPasswordField(
                        label: '密码',
                        value: widget.item.password,
                        isObscured: _obscurePassword,
                        displayPassword: _obscurePassword
                            ? '•' *
                                  (widget
                                      .item
                                      .password
                                      .length) // 密码为null时显示0个圆点
                            : widget.item.password,

                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onCopy: () =>
                            ClipboardHelper.copyToClipboard(context, widget.item.password, '密码'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 右列 - 网站和备注
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 网站
                      _buildCredentialField(
                        label: '网站',
                        value: widget.item.website.isNotEmpty
                            ? widget.item.website
                            : '未设置',
                        icon: Icons.link,
                        onCopy: () =>
                            ClipboardHelper.copyToClipboard(context, widget.item.website, '网站'),
                      ),
                      const SizedBox(height: 12),
                      // 备注
                      _buildCredentialField(
                        label: '备注',
                        value: widget.item.notes.isNotEmpty
                            ? widget.item.notes
                            : '未添加任何备注',
                        icon: Icons.note,
                        onCopy: () => ClipboardHelper.copyToClipboard(context, widget.item.notes, '备注'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: label == '网站' && value != '未设置'
                    ? GestureDetector(
                        onTap: () async {
                          String url = value;
                          // 确保URL有协议前缀
                          if (!url.startsWith('http://') &&
                              !url.startsWith('https://')) {
                            url = 'https://$url';
                          }
                          bool success = await UrlLauncherHelper.launchUrl(url);
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('无法打开链接')),
                            );
                          }
                        },
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: onCopy,
                tooltip: '复制',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String value,
    required String displayPassword,
    required bool isObscured,
    required VoidCallback onToggle,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayPassword,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                ),
                onPressed: onToggle,
                tooltip: isObscured ? '显示密码' : '隐藏密码',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: onCopy,
                tooltip: '复制',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }
}
