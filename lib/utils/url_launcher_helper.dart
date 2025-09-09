import 'package:url_launcher/url_launcher.dart' as url_launcher;

class UrlLauncherHelper {
  /// 启动URL链接
  /// [url] 需要打开的URL链接
  /// 返回是否成功打开
  static Future<bool> launchUrl(String url) async {
    // 确保URL有正确的协议前缀
    final uri = Uri.parse(url);
    if (await canLaunchUrl(url)) {
      return await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
    } else {
      return false;
    }
  }

  /// 检查URL是否可以被打开
  static Future<bool> canLaunchUrl(String url) async {
    final uri = Uri.parse(url);
    return await url_launcher.canLaunchUrl(uri);
  }
}