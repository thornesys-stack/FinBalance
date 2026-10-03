import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/auth_feature_flags.dart';
import '../domain/phone_country.dart';
import 'auth_controller.dart';
import 'auth_validators.dart';
import 'widgets/auth_message_banner.dart';
import 'widgets/auth_or_divider.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_tabs.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/glass_surface.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/phone_country_picker.dart';

/// 登录方式。
enum _LoginMethod { email, phone }

/// 手机号登录的两种凭证形态。
enum _PhoneLoginMode { code, password }

/// 登录页。
///
/// 三种登录路径共用一张卡片：
///   1. 账号 + 密码：标识框接受邮箱 / 手机号 / 账号名（后端目前实际只认邮箱）；
///   2. 手机号：验证码 / 密码两种模式；
///   3. Google（OAuth）。
///
/// 职责边界：只做「收集输入 → 校验 → 交给 [AuthController] → 展示结果」。
/// 不持有登录态、不碰 token、不自己导航 —— 登录成功后由 [AuthGate] 换根。
class LoginPage extends StatefulWidget {
  final AuthController controller;

  /// 切到注册页。
  ///
  /// 传回调而不是在这里 `Navigator.push`：登录成功时 [AuthGate] 会把
  /// 整棵子树换成主界面，压在栈上的注册页会残留成"幽灵路由"，
  /// 用户按返回键会回到一个已经没有意义的登录页。
  final VoidCallback onGoToRegister;

  const LoginPage({
    super.key,
    required this.controller,
    required this.onGoToRegister,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  /// 手机号字段单独持有 key —— "获取验证码"只校验它一个。
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _phoneController = TextEditingController();

  final _codeController = TextEditingController();

  final _phonePasswordController = TextEditingController();

  final _passwordFocus = FocusNode();

  final _phoneFocus = FocusNode();

  final _codeFocus = FocusNode();

  final _phonePasswordFocus = FocusNode();

  _LoginMethod _method = _LoginMethod.email;

  _PhoneLoginMode _phoneMode = _PhoneLoginMode.code;

  PhoneCountry _country = PhoneCountry.china;

  bool _obscurePassword = true;

  bool _obscurePhonePassword = true;

  /// 验证码重发倒计时剩余秒数；0 表示可以发送。
  int _countdown = 0;

  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();

    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _phonePasswordController.dispose();

    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    _phonePasswordFocus.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 交互
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    // 先收键盘：验证失败时错误文案就在输入框下方，键盘不收起来会被挡住。
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final controller = widget.controller;

    switch (_method) {
      case _LoginMethod.email:
        await controller.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

      case _LoginMethod.phone:
        final phone = PhoneCountry.normalize(_phoneController.text);

        if (_phoneMode == _PhoneLoginMode.code) {
          await controller.loginWithPhoneCode(
            countryCode: _country.dialCode,
            phone: phone,
            code: PhoneCountry.normalize(_codeController.text),
          );
        } else {
          await controller.loginWithPhonePassword(
            countryCode: _country.dialCode,
            phone: phone,
            password: _phonePasswordController.text,
          );
        }
    }

    // 成功 / 失败都不在这里判分支：
    //   成功 → AuthGate 收到通知后换根到主界面；
    //   失败 → controller.errorMessage 变化，卡片里的横幅自动出现。
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();

    // 只校验手机号。整体 validate() 会把还没填的验证码框一起标红，
    // 而用户此刻的意图只是"先要个验证码"。
    if (!(_phoneFieldKey.currentState?.validate() ?? false)) {
      return;
    }

    final sent = await widget.controller.sendSmsCode(
      countryCode: _country.dialCode,
      phone: PhoneCountry.normalize(_phoneController.text),
    );

    if (!mounted || !sent) {
      return;
    }

    _startCountdown(widget.controller.smsResendSeconds);

    _codeFocus.requestFocus();
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();

    final total =
        seconds <= 0 ? AuthFeatureFlags.defaultSmsResendSeconds : seconds;

    setState(() => _countdown = total);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final next = _countdown - 1;

      setState(() => _countdown = next < 0 ? 0 : next);

      if (next <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _pickCountry() async {
    final picked = await showPhoneCountryPicker(context, selected: _country);

    if (picked == null || !mounted) {
      return;
    }

    setState(() => _country = picked);

    widget.controller.clearError();
  }

  Future<void> _onGooglePressed() async {
    FocusScope.of(context).unfocus();

    await widget.controller.signInWithGoogle();
  }

  void _switchMethod(_LoginMethod method) {
    if (method == _method) {
      return;
    }

    setState(() => _method = method);

    widget.controller.clearError();
  }

  void _switchPhoneMode(_PhoneLoginMode mode) {
    if (mode == _phoneMode) {
      return;
    }

    setState(() => _phoneMode = mode);

    widget.controller.clearError();
  }

  // ---------------------------------------------------------------------------
  // 构建
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: '欢迎回来',

      subtitle: '登录后继续管理你的资产与账单',

      child: AnimatedBuilder(
        animation: widget.controller,

        builder: (context, _) {
          final controller = widget.controller;

          final isSubmitting = controller.isSubmitting;

          return Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                AuthTabs<_LoginMethod>(
                  options: const [
                    AuthTabOption(_LoginMethod.email, '账号登录'),
                    AuthTabOption(_LoginMethod.phone, '手机号登录'),
                  ],

                  selected: _method,

                  onChanged: _switchMethod,

                  enabled: !isSubmitting,
                ),

                const SizedBox(height: 20),

                if (_method == _LoginMethod.email)
                  ..._buildEmailFields(isSubmitting)
                else
                  ..._buildPhoneFields(controller, isSubmitting),

                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),

                  AuthMessageBanner(message: controller.errorMessage!),
                ],

                if (controller.infoMessage != null) ...[
                  const SizedBox(height: 16),

                  AuthMessageBanner(
                    message: controller.infoMessage!,
                    isError: false,
                  ),
                ],

                const SizedBox(height: 22),

                AuthSubmitButton(
                  label: '登录',
                  isSubmitting: isSubmitting,
                  onPressed: _submit,
                ),

                const SizedBox(height: 22),

                const AuthOrDivider(),

                const SizedBox(height: 18),

                GoogleSignInButton(
                  isSubmitting: isSubmitting,
                  onPressed: _onGooglePressed,
                ),

                // 后端与 SDK 都没接入时先把话说在前面，
                // 而不是等用户点了再弹一句"暂时不可用"。
                if (!AuthFeatureFlags.googleLogin) ...[
                  const SizedBox(height: 8),

                  Text(
                    'Google 登录待后端接入 OAuth',

                    textAlign: TextAlign.center,

                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      // 用 textSecondary 而不是 textTertiary：这句是「为什么点不动」
                      // 的唯一解释，不能淡到读不清。
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    TextButton(
                      onPressed: isSubmitting ? null : widget.onGoToRegister,

                      child: const Text('立即注册'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 账号（邮箱 / 手机号 / 账号名）+ 密码
  // ---------------------------------------------------------------------------

  List<Widget> _buildEmailFields(bool isSubmitting) {
    return [
      AuthTextField(
        controller: _emailController,

        label: '邮箱 / 手机号',

        hint: 'you@example.com',

        icon: Icons.account_circle_outlined,

        // 键盘类型保持 emailAddress 而不是 text：它同时给出 @、. 和数字行，
        // 输邮箱和输手机号都用得上。
        keyboardType: TextInputType.emailAddress,

        textInputAction: TextInputAction.next,

        // username 而不是 email：密码管理器按这个提示匹配"账号"凭据，
        // 提示成 email 会让它跳过存成用户名的那条记录。
        autofillHints: const [AutofillHints.username],

        enabled: !isSubmitting,

        // 按形状分流：含 @ 走邮箱、纯数字走手机号、其余按账号名。
        // 只认邮箱格式的话，手机号 / 账号名会被直接判死。
        // 注册页共用同一条规则（见 AuthValidators.identifier）。
        validator: AuthValidators.identifier,

        onChanged: (_) => widget.controller.clearError(),

        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      ),

      const SizedBox(height: 14),

      AuthTextField(
        controller: _passwordController,

        focusNode: _passwordFocus,

        label: '密码',

        icon: Icons.lock_outline_rounded,

        obscureText: _obscurePassword,

        textInputAction: TextInputAction.done,

        autofillHints: const [AutofillHints.password],

        enabled: !isSubmitting,

        validator: AuthValidators.loginPassword,

        onChanged: (_) => widget.controller.clearError(),

        onFieldSubmitted: (_) => _submit(),

        suffixIcon: _visibilityToggle(
          obscured: _obscurePassword,
          enabled: !isSubmitting,
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // 手机号
  // ---------------------------------------------------------------------------

  List<Widget> _buildPhoneFields(AuthController controller, bool isSubmitting) {
    return [
      // 未接入时的常驻说明。放在最上面，用户还没开始输就知道现状。
      if (!AuthFeatureFlags.phoneLogin) ...[
        AuthMessageBanner(
          message: AuthFeatureFlags.phoneUnavailableMessage,
          isError: false,
        ),

        const SizedBox(height: 16),
      ],

      AuthTextField(
        controller: _phoneController,

        fieldKey: _phoneFieldKey,

        focusNode: _phoneFocus,

        label: '手机号',

        hint: '13800000000',

        icon: Icons.phone_outlined,

        keyboardType: TextInputType.phone,

        textInputAction: TextInputAction.next,

        enabled: !isSubmitting,

        validator:
            (value) => AuthValidators.phone(value, dialCode: _country.dialCode),

        onChanged: (_) => controller.clearError(),

        prefixIcon: _buildCountryPicker(enabled: !isSubmitting),
      ),

      const SizedBox(height: 16),

      AuthTabs<_PhoneLoginMode>(
        options: const [
          AuthTabOption(_PhoneLoginMode.code, '验证码登录'),
          AuthTabOption(_PhoneLoginMode.password, '密码登录'),
        ],

        selected: _phoneMode,

        onChanged: _switchPhoneMode,

        dense: true,

        enabled: !isSubmitting,
      ),

      const SizedBox(height: 14),

      if (_phoneMode == _PhoneLoginMode.code)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthTextField(
                controller: _codeController,

                focusNode: _codeFocus,

                label: '验证码',

                icon: Icons.sms_outlined,

                keyboardType: TextInputType.number,

                textInputAction: TextInputAction.done,

                enabled: !isSubmitting,

                validator: AuthValidators.smsCode,

                onChanged: (_) => controller.clearError(),

                onFieldSubmitted: (_) => _submit(),
              ),
            ),

            const SizedBox(width: 10),

            _SendCodeButton(
              countdown: _countdown,

              isSending: controller.isSendingCode,

              enabled: !isSubmitting && !controller.isSendingCode,

              onPressed: _sendCode,
            ),
          ],
        )
      else
        AuthTextField(
          controller: _phonePasswordController,

          focusNode: _phonePasswordFocus,

          label: '密码',

          icon: Icons.lock_outline_rounded,

          obscureText: _obscurePhonePassword,

          textInputAction: TextInputAction.done,

          enabled: !isSubmitting,

          validator: AuthValidators.phonePassword,

          onChanged: (_) => controller.clearError(),

          onFieldSubmitted: (_) => _submit(),

          suffixIcon: _visibilityToggle(
            obscured: _obscurePhonePassword,

            enabled: !isSubmitting,

            onPressed:
                () => setState(
                  () => _obscurePhonePassword = !_obscurePhonePassword,
                ),
          ),
        ),
    ];
  }

  /// 区号选择器：作为手机号输入框的前置控件。
  Widget _buildCountryPicker({required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),

      child: InkWell(
        onTap: enabled ? _pickCountry : null,

        borderRadius: BorderRadius.circular(10),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _country.dialCode,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 2),

              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 10),

              // 一条细竖线，把"区号"和"号码"在视觉上切开 ——
              // 没有它，用户会以为 +86 也是号码的一部分。
              Container(width: 1, height: 18, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visibilityToggle({
    required bool obscured,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,

      tooltip: obscured ? '显示密码' : '隐藏密码',

      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
      ),
    );
  }
}

/// 「获取验证码」按钮：三个状态 —— 可发送 / 发送中 / 倒计时。
///
/// 玻璃按钮的冷色淡染版本：填充是极淡的蓝，文字用 [AppColors.coolMid]。
/// 不用实心描边按钮是因为它紧挨着输入框，实心边框会让这一行出现两个
/// 重量相当的边框，视线会被拉过去 —— 而它只是输入框的附属操作。
class _SendCodeButton extends StatelessWidget {
  final int countdown;

  final bool isSending;

  final bool enabled;

  final VoidCallback onPressed;

  const _SendCodeButton({
    required this.countdown,
    required this.isSending,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final counting = countdown > 0;

    final canPress = enabled && !counting;

    return GlassButton(
      // 与输入框同高，这样并排时两者底边是对齐的
      // （InputDecoration 的 contentPadding 14 + 文字行高 + 1px 描边 ≈ 50）。
      height: 50,

      radius: 14,

      fill:
          canPress
              ? AppColors.coolMid.withValues(alpha: 0.10)
              : AppColors.coolMid.withValues(alpha: 0.04),

      borderColor:
          canPress
              ? AppColors.coolMid.withValues(alpha: 0.30)
              : AppColors.coolDeep.withValues(alpha: 0.08),

      padding: const EdgeInsets.symmetric(horizontal: 14),

      onPressed: canPress ? onPressed : null,

      child:
          isSending
              ? const SizedBox(
                width: 16,
                height: 16,

                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.coolMid,
                ),
              )
              : Text(
                counting ? '${countdown}s 后重发' : '获取验证码',

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: canPress ? AppColors.coolMid : AppColors.textTertiary,
                ),
              ),
    );
  }
}
