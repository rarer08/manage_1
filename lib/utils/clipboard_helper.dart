import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 剪贴板工具类，提供复制文本到剪贴板的功能
class ClipboardHelper {
  /// 将文本复制到剪贴板并显示提示信息
  /// 
  /// [context] - 构建上下文，用于显示SnackBar
  /// [text] - 要复制的文本内容
  /// [label] - 复制内容的标签，用于提示信息
  /// [showToast] - 是否显示提示信息，默认为true
  static void copyToClipboard(
    BuildContext context,
    String text,
    String label,
    {bool showToast = true}
  ) {
    // 设置数据到剪贴板
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // 仅当需要显示提示时执行
      if (showToast && context.mounted) {
        // 移除当前显示的SnackBar，确保只显示最新的复制提醒
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        
        // 显示新的SnackBar提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制 $label 到剪贴板'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}