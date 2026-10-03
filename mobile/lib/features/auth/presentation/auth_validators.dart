import '../domain/auth_feature_flags.dart';

/// 认证表单的校验规则。
///
/// 规则与后端 `backend/app/api/auth.py` 的 Pydantic 模型对齐：
///   - `RegisterRequest.password`: min_length=8, max_length=128
///   - `RegisterRequest.name`: max_length=50，可为空
///   - `LoginRequest.password`: min_length=1（登录侧不设长度下限）
///   - `LoginRequest.email` / `RegisterRequest.email`: EmailStr
///
/// 最后一条划定了账号字段的边界：后端的登录与注册都只有 `email`
/// 一个标识字段，且都是 EmailStr。所以「不把账号锁死在邮箱上」
/// （见 [identifier]）指的是**前端不提前拦截**，而不是后端已经
/// 接受任意字符串 —— 今天输入手机号，本地会放行，随后被后端 422 拒掉。
/// 之所以仍然放宽，是为了让后端补上手机号 / 用户名登录时前端无需返工；
/// 期间由界面上的说明文案把这条边界讲清楚（见 `AuthFeatureFlags`）。
///
/// 刻意在前端重复一遍校验：后端校验失败要走一次网络往返、返回 422，
/// 用户等待 1~2 秒才知道"密码太短"。本地先拦一遍是纯体验优化，
/// **不是**安全边界 —— 真正的把关永远在服务端。
class AuthValidators {
  const AuthValidators._();

  /// 后端的最小密码长度。
  static const int minPasswordLength = 8;

  /// 后端的最大密码长度。
  static const int maxPasswordLength = 128;

  /// 后端的姓名最大长度。
  static const int maxNameLength = 50;

  /// 登录标识字段的长度上限。
  ///
  /// 取 254 是因为它同时是 RFC 5321 对邮件地址的上限 —— 登录标识在
  /// 绝大多数情况下就是邮箱，共用一个上限不会误伤。
  static const int maxIdentifierLength = 254;

  /// 够用的邮箱格式。
  ///
  /// 刻意不追求 RFC 5322 全量：那种正则又长又难维护，而且真写全了
  /// 也依然只能给用户一句"格式不正确"。这里保证「有 @、域名有至少一个点、
  /// 本地部分无空格」即可，剩余交给后端 EmailStr 做权威判断。
  static final RegExp _emailPattern = RegExp(
    r"^[\w.!#$%&'*+/=?^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
    r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  /// 是否"长得像邮箱"。
  ///
  /// **不是**校验规则（规则见 [identifier]），而是给界面用来判断
  /// "这个输入能不能过得了后端当前的 `EmailStr`"—— 注册页据此把
  /// 「后端尚未支持非邮箱注册」这条边界讲成中文，而不是把一个英文的
  /// Pydantic 报错丢给用户。
  static bool looksLikeEmail(String value) =>
      _emailPattern.hasMatch(value.trim());

  /// 账号标识：邮箱 / 手机号 / 账号名都可以。登录与注册**共用**同一条规则。
  ///
  /// 不锁死在邮箱上的做法**不是**"什么都不校验"，而是按形状分流：
  ///   1. 含 `@` 的按邮箱查 —— 这是唯一能在本地判断对错的一类，
  ///      不在这里拦住就只能等后端返 422；
  ///   2. 纯数字（可带前导 `+`）的按手机号查，且只查位数范围；
  ///   3. 其余按账号名放宽，只约束长度和字符集，不预设格式。
  ///
  /// 登录与注册共用而不是各写一套：两者提交的是同一个字段、对应同一组
  /// 后端约束，规则一旦分叉，用户就会遇到"注册时放行、登录时判死"这种
  /// 自相矛盾。差别只在提示文案（由页面各自的 helperText 承担）。
  ///
  /// 三种情况最终都提交到后端同一个 `email` 字段。所以放宽的意义是
  /// "为后端将来支持手机号 / 用户名留出空间"，今天输入手机号仍会被
  /// 后端的 EmailStr 拦下 —— 前端不再提前拦截而已。
  static String? identifier(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      return '请输入邮箱或手机号';
    }

    if (text.length > maxIdentifierLength) {
      return '长度超出限制';
    }

    if (text.contains('@')) {
      return _emailPattern.hasMatch(text) ? null : '邮箱格式不正确';
    }

    // 校验的就是即将提交的那个字符串，所以空格直接拦掉、不做静默清洗 ——
    // 清成另一个值再提交，用户会莫名其妙：他看到输入框里明明是这个。
    if (RegExp(r'\s').hasMatch(text)) {
      return '不能包含空格';
    }

    // 纯数字（可带前导 +）→ 按手机号查，只查位数范围。各国编号规则差异极大
    // （英国、德国都是变长的），前端硬编码一套"通用"规则只会误伤真实号码。
    if (RegExp(r'^\+?\d+$').hasMatch(text)) {
      final digits = text.startsWith('+') ? text.substring(1) : text;

      if (digits.length < 6 || digits.length > 15) {
        return '手机号位数不正确';
      }

      return null;
    }

    // 其余按账号名放宽：只约束长度和字符集。
    if (text.length < 3) {
      return '账号至少 3 个字符';
    }

    if (!RegExp(r'^[A-Za-z0-9._+-]+$').hasMatch(text)) {
      return '账号只能包含字母、数字与 . _ + -';
    }

    return null;
  }

  /// 注册用账号标识：在 [identifier] 之上多一道「后端能力边界」。
  ///
  /// 后端 `RegisterRequest.email` 是 EmailStr，非邮箱输入发出去只会换回
  /// 422。放宽 [identifier] 是为了后端将来支持时前端不必返工，但在后端
  /// 真的支持之前，让用户填完整张表单（含密码、确认密码、主货币）再看
  /// 一句英文的 Pydantic 报错，代价太大 —— **注册失败会丢掉全部已填内容**。
  ///
  /// 所以这里把边界讲成中文、落在字段的错误位上；注意它只在 [identifier]
  /// 放行之后才生效，规则本身与登录始终是同一条。
  ///
  /// [allowNonEmail] 由 `AuthFeatureFlags.nonEmailRegistration` 驱动，
  /// 后端开放后整段判断自动消失。
  static String? registerIdentifier(
    String? value, {
    bool allowNonEmail = false,
  }) {
    final invalid = identifier(value);

    if (invalid != null) {
      return invalid;
    }

    if (!allowNonEmail && !looksLikeEmail(value ?? '')) {
      return AuthFeatureFlags.nonEmailRegisterBlockedMessage;
    }

    return null;
  }

  /// 登录用：只要求非空。
  ///
  /// 为什么登录不校验最小长度：密码长度规则是后加的，
  /// 老账号里可能存在不足 8 位的密码。在这里拦住的话，
  /// 那些用户会被永久锁在门外，而且提示还是"密码至少 8 位"——
  /// 他会以为自己记错了密码。
  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return '请输入密码';
    }

    if ((value ?? '').length > maxPasswordLength) {
      return '密码长度超出限制';
    }

    return null;
  }

  /// 注册用：与后端 min_length=8 对齐。
  static String? registerPassword(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return '请输入密码';
    }

    if (text.length < minPasswordLength) {
      return '密码至少 $minPasswordLength 位';
    }

    if (text.length > maxPasswordLength) {
      return '密码不能超过 $maxPasswordLength 位';
    }

    return null;
  }

  /// 确认密码。
  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) {
      return '请再次输入密码';
    }

    if (value != password) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  /// 用户名：选填，只校验上限。
  static String? name(String? value) {
    if ((value ?? '').trim().length > maxNameLength) {
      return '用户名不能超过 $maxNameLength 个字符';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 手机号登录（后端尚未实现，校验规则按 E.164 通用约定 + 大陆规则先定下来）
  // ---------------------------------------------------------------------------

  /// 中国大陆手机号：1 开头，第二位 3–9，共 11 位。
  static final RegExp _cnMobilePattern = RegExp(r'^1[3-9]\d{9}$');

  /// 验证码位数范围。后端未定义，先取 4–8 位这种最常见区间。
  static const int minSmsCodeLength = 4;

  static const int maxSmsCodeLength = 8;

  /// 手机号（本地号，不含区号）。
  ///
  /// 只对中国大陆做严格校验，其它地区走宽松规则 ——
  /// 各国编号规则差异极大（英国、德国都是变长的），
  /// 在前端硬编码一套"通用"规则只会误伤真实号码。
  /// 真正的权威判断必须由后端 + 短信网关完成。
  static String? phone(String? value, {required String dialCode}) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return '请输入手机号';
    }

    if (dialCode == '+86') {
      if (!_cnMobilePattern.hasMatch(digits)) {
        return '请输入有效的 11 位手机号';
      }
      return null;
    }

    if (digits.length < 4 || digits.length > 15) {
      return '手机号位数不正确';
    }

    return null;
  }

  /// 短信验证码。
  static String? smsCode(String? value) {
    final text = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) {
      return '请输入验证码';
    }

    if (text.length < minSmsCodeLength || text.length > maxSmsCodeLength) {
      return '验证码应为 $minSmsCodeLength–$maxSmsCodeLength 位数字';
    }

    return null;
  }

  /// 手机号登录的密码分支。
  ///
  /// 与 [loginPassword] 同口径：只要求非空，不设长度下限 ——
  /// 密码长度规则是后加的，老账号可能不足 8 位，在这里拦住会把
  /// 那些用户永久锁在门外。
  static String? phonePassword(String? value) => loginPassword(value);
}
