// 密码条目数据模型类
class PasswordItem {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String website;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordItem({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.website,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从数据库映射创建PasswordItem实例
  factory PasswordItem.fromMap(Map<String, dynamic> map) {
    return PasswordItem(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      website: map['website'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // 将PasswordItem实例转换为数据库映射
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 创建一个复制实例的方法，方便更新部分字段
  PasswordItem copyWith({
    int? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}