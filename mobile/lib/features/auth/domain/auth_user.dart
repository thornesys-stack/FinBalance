/// 登录用户。
///
/// JSON 来源有两处，字段一致（都是 snake_case）：
///   - `POST /api/v1/auth/login|register` 的 `data.user`
///   - `GET /api/v1/auth/me` 的 `data`
///
/// 注意与 `/api/v1/user` 的区别：后者返回 `{user: {...}, data_summary: {...}}`，
/// 多带一份数据统计，用于「删除数据前提示将删除 N 笔交易」。
/// 认证流程只需要身份本身，所以走 /auth/me。
class AuthUser {
  final String id;

  final String email;

  final String? name;

  /// 界面语言 [架构 §16 Localization First]，如 zh-CN / en-US / ja-JP。
  final String locale;

  /// IANA 时区名，如 Asia/Shanghai。
  final String timeZone;

  /// 主货币 [架构 §17]，ISO 4217，如 CNY。
  final String baseCurrency;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    required this.locale,
    required this.timeZone,
    required this.baseCurrency,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: nullableText(json['name']),
      locale: json['locale']?.toString() ?? 'zh-CN',
      timeZone: json['time_zone']?.toString() ?? 'Asia/Shanghai',
      baseCurrency: json['base_currency']?.toString() ?? 'CNY',
    );
  }

  /// 界面上显示的名字。注册时用户名为选填，所以要有回退。
  String get displayName {
    final value = name?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email.isEmpty ? '未登录用户' : email;
  }

  /// 头像占位用的首字母。
  ///
  /// 用 runes 而不是 `displayName[0]`：后者按 UTF-16 码元取字符，
  /// 遇到 emoji 或补充平面字符会截出半个字符、渲染成乱码方块。
  String get initial {
    final source = displayName.trim();
    if (source.isEmpty) {
      return '?';
    }
    return String.fromCharCode(source.runes.first).toUpperCase();
  }

  /// 把空串归一成 null —— 后端 `name` 可空，但可能返回 ""。
  static String? nullableText(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
