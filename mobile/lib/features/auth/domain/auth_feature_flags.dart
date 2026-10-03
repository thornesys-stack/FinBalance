/// 认证方式的可用性开关。
///
/// 存在的理由：手机号登录与 Google 登录的**前端实现是完整的**，
/// 但后端（backend/app/api/auth.py）目前只有邮箱 + 密码，
/// 契约文档也把「手机号登录 API」列在待决清单里。
///
/// 如果直接放行，"点一下发送验证码"会得到 404（或者被后端当成邮箱去校验），
/// 用户看到的是一个看起来能用、实际烂掉的按钮 —— 这比没有按钮更糟：
/// 他会以为是自己的手机号有问题。
///
/// 所以这里用编译期常量把边界画清楚：
///   - 关闭时：界面照常展示、输入照常校验、点击给出**明确原因**，不发请求；
///   - 打开时：走真实调用链（datasource / repository 已经全部写好）。
///
/// ⚠️ 打开开关前必须确认后端已上线对应端点，否则等于把上面的坑重新挖回来。
class AuthFeatureFlags {
  const AuthFeatureFlags._();

  /// 手机号登录（短信验证码 / 手机号 + 密码）。
  ///
  /// 前置条件：后端提供
  ///   - `POST /api/v1/auth/sms/send`
  ///   - `POST /api/v1/auth/login/phone`
  static const bool phoneLogin = false;

  /// Google 登录。
  ///
  /// 除后端的 `POST /api/v1/auth/google` 之外，前端还缺两样东西，
  /// 补齐后才谈得上打开：
  ///   1. `google_sign_in` SDK（pubspec 目前没有这个依赖）——
  ///      没有它就拿不到 id_token，本方法的入参无从产生；
  ///   2. 平台配置（Android `google-services.json` / iOS URL Scheme）。
  static const bool googleLogin = false;

  /// 非邮箱注册（手机号 / 用户名注册）。
  ///
  /// 与上面两个开关**不同**：这里前端不缺任何东西，缺的只有后端 ——
  /// `RegisterRequest.email` 是 EmailStr 且带唯一约束，账号的标识字段
  /// 就是它。所以关闭时不是"禁用输入"，而是把这条边界提前讲清楚：
  /// 校验照常放宽（注册与登录共用 `AuthValidators.identifier`），
  /// 只是字段下方多一行说明，用户不必填完整张表才发现注册不了。
  ///
  /// 后端把注册改成接受手机号 / 用户名之后翻成 true 即可，前端一行不用改。
  static const bool nonEmailRegistration = false;

  /// 注册页账号字段下方的说明；开关打开后自动消失（返回 null 即不渲染）。
  static String? get nonEmailRegisterHint =>
      nonEmailRegistration ? null : _nonEmailRegisterHint;

  static const String _nonEmailRegisterHint = '目前仅支持用邮箱注册，手机号 / 账号名待后端开放';

  /// 校验层放行、但后端还收不下时给出的原因（落在表单错误位，红色）。
  ///
  /// 与上面那条常驻说明不是一回事：说明是"提示"，这条是"拦下来"。
  /// 两者不会同时出现 —— 字段有错误时 [InputDecoration] 用错误顶掉说明。
  static const String nonEmailRegisterBlockedMessage =
      '注册暂只支持邮箱，手机号 / 账号名待后端开放';

  /// 短信验证码的重发间隔（秒）。
  ///
  /// 后端响应里的 `resend_after` 优先；拿不到时用这个兜底。
  /// 定 60 秒是因为短信按条计费，短于此间隔的重发请求基本都来自误触。
  static const int defaultSmsResendSeconds = 60;

  // ---------------------------------------------------------------------------
  // 未接入时的用户可见文案
  //
  // 刻意写得短：这是给**用户**看的，他关心的是"现在该怎么办"，
  // 而不是缺了哪个端点。端点清单在上面的类和 ApiEndpoints 的注释里，
  // 需要排查的人自然会去看那里。
  //
  // 集中放在这里而不是散在页面里：开关打开后这些常量会一起失效，
  // 放在一处才删得干净。
  // ---------------------------------------------------------------------------

  static const String phoneUnavailableMessage = '手机号登录尚未接入，暂时请先用账号登录';

  static const String googleUnavailableMessage = 'Google 登录尚未接入，暂时请先用账号登录';

  /// 开关已打开、但拿不到 id_token（缺少 SDK 或用户取消授权）。
  static const String googleSdkMissingMessage =
      '未能获取 Google 授权凭证，请确认已接入 google_sign_in SDK 并完成平台配置。';
}
