import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/auth_feature_flags.dart';
import 'auth_controller.dart';
import 'auth_validators.dart';
import 'widgets/auth_message_banner.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_text_field.dart';

/// 主货币选项。
///
/// code 必须落在 `Currency.fromCode` 支持的白名单里
/// （lib/core/money/currency.dart）—— 后端对 `base_currency` 只校验
/// 「3 个字符」，并不会拦住 'XYZ'；一旦前端放进去，后续所有金额
/// 转换都会在 `Currency.fromCode` 抛 FormatException。这里只列已支持的五种。
const List<_CurrencyOption> _currencyOptions = [
  _CurrencyOption(code: 'CNY', label: 'CNY ¥'),
  _CurrencyOption(code: 'USD', label: 'USD \$'),
  _CurrencyOption(code: 'EUR', label: 'EUR €'),
  _CurrencyOption(code: 'JPY', label: 'JPY ¥'),
  _CurrencyOption(code: 'GBP', label: 'GBP £'),
];

class _CurrencyOption {
  final String code;

  final String label;

  const _CurrencyOption({required this.code, required this.label});
}

/// 注册页。
///
/// 与后端的字段映射（`RegisterRequest`）：
///   name          → 用户名，选填
///   email         → 账号标识。界面按「邮箱 / 手机号」呈现、校验也放宽，
///                   但后端字段仍是 `EmailStr` + 唯一约束 —— 所以这里
///                   必须把边界讲清楚（见 [AuthFeatureFlags.nonEmailRegistration]），
///                   否则用户要填完整张表才发现注册不了。
///   password      → 密码
///   locale        → 固定 zh-CN（界面语言由 App 决定，不该让用户在注册时选）
///   time_zone     → 固定 Asia/Shanghai（同上）
///   base_currency → 主货币，用户可选
class RegisterPage extends StatefulWidget {
  final AuthController controller;

  /// 切回登录页，理由同 [LoginPage.onGoToRegister]。
  final VoidCallback onGoToLogin;

  const RegisterPage({
    super.key,
    required this.controller,
    required this.onGoToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmController = TextEditingController();

  final _emailFocus = FocusNode();

  final _passwordFocus = FocusNode();

  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;

  bool _obscureConfirm = true;

  String _baseCurrency = 'CNY';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.controller.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      baseCurrency: _baseCurrency,
    );

    // 同登录页：成功后由 AuthGate 换根到主界面。
    // 后端注册接口会**同时签发令牌**（201 + TokenPairOut），
    // 所以这里不需要再跳一次登录。
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: '创建账号',

      subtitle: '几秒钟即可开始记录你的资产与账单',

      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;

          final isSubmitting = controller.isSubmitting;

          final error = controller.errorMessage;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _nameController,

                  label: '用户名（选填）',

                  hint: '怎么称呼你',

                  icon: Icons.person_outline_rounded,

                  textInputAction: TextInputAction.next,

                  autofillHints: const [AutofillHints.name],

                  maxLength: AuthValidators.maxNameLength,

                  enabled: !isSubmitting,

                  validator: AuthValidators.name,

                  onChanged: (_) => controller.clearError(),

                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  controller: _emailController,

                  focusNode: _emailFocus,

                  // 与登录页同一套措辞：在用户眼里两页的账号字段就是同一个
                  // 东西，一边写"邮箱"一边写"邮箱 / 手机号"会让人以为是
                  // 两种互不相通的账号。
                  label: '邮箱 / 手机号',

                  hint: 'you@example.com',

                  icon: Icons.account_circle_outlined,

                  // 邮箱键盘同时带 @ 和数字行，两类输入都用得上。
                  keyboardType: TextInputType.emailAddress,

                  textInputAction: TextInputAction.next,

                  // 密码管理器按 username 匹配账号凭据；提示成 email
                  // 会让它跳过存成用户名的那条记录。
                  autofillHints: const [AutofillHints.username],

                  enabled: !isSubmitting,

                  // 与登录共用一条分流规则（含 @ 走邮箱、纯数字走手机号、
                  // 其余按账号名），分叉的后果是"注册放行、登录判死"这种
                  // 自相矛盾。
                  //
                  // 注册多一道后端能力边界，由开关驱动；开关打开后规则与
                  // 登录完全一致（见 AuthValidators.registerIdentifier）。
                  validator:
                      (value) => AuthValidators.registerIdentifier(
                        value,
                        allowNonEmail: AuthFeatureFlags.nonEmailRegistration,
                      ),

                  // 提前讲清后端边界：注册失败会丢掉整张已填的表单，
                  // 比登录失败昂贵得多，不能等提交后再说。
                  helperText: AuthFeatureFlags.nonEmailRegisterHint,

                  onChanged: (_) => controller.clearError(),

                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  controller: _passwordController,

                  focusNode: _passwordFocus,

                  label: '密码',

                  hint: '至少 ${AuthValidators.minPasswordLength} 位',

                  icon: Icons.lock_outline_rounded,

                  obscureText: _obscurePassword,

                  textInputAction: TextInputAction.next,

                  autofillHints: const [AutofillHints.newPassword],

                  enabled: !isSubmitting,

                  validator: AuthValidators.registerPassword,

                  onChanged: (_) {
                    controller.clearError();

                    // 密码改了之后，"两次不一致"的结论就作废了，
                    // 重新校验确认框，让用户看到的是当前事实。
                    if (_confirmController.text.isNotEmpty) {
                      _formKey.currentState?.validate();
                    }
                  },

                  onFieldSubmitted: (_) => _confirmFocus.requestFocus(),

                  suffixIcon: IconButton(
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),

                    tooltip: _obscurePassword ? '显示密码' : '隐藏密码',

                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  controller: _confirmController,

                  focusNode: _confirmFocus,

                  label: '确认密码',

                  icon: Icons.lock_reset_rounded,

                  obscureText: _obscureConfirm,

                  textInputAction: TextInputAction.done,

                  enabled: !isSubmitting,

                  validator:
                      (value) => AuthValidators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),

                  onChanged: (_) => controller.clearError(),

                  onFieldSubmitted: (_) => _submit(),

                  suffixIcon: IconButton(
                    onPressed:
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),

                    tooltip: _obscureConfirm ? '显示密码' : '隐藏密码',

                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _BaseCurrencyPicker(
                  value: _baseCurrency,

                  enabled: !isSubmitting,

                  onChanged: (code) => setState(() => _baseCurrency = code),
                ),

                if (error != null) ...[
                  const SizedBox(height: 16),

                  AuthMessageBanner(message: error),
                ],

                const SizedBox(height: 24),

                AuthSubmitButton(
                  label: '注册',
                  isSubmitting: isSubmitting,
                  onPressed: _submit,
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有账号？',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    TextButton(
                      onPressed: isSubmitting ? null : widget.onGoToLogin,

                      child: const Text('去登录'),
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
}

/// 主货币选择。
///
/// 用 [ChoiceChip] 而不是下拉框：选项只有 5 个，全部平铺出来
/// 比"点开 → 滚动 → 选中"少两步，也不会被键盘遮挡。
///
/// 选中态用冷色淡染 + 描边，不填实色：
/// 5 个芯片平铺在卡片上，任何一个填满实色都会成为画面里最重的元素，
/// 把注意力从"填表单"拽到"选货币"上。
class _BaseCurrencyPicker extends StatelessWidget {
  final String value;

  final bool enabled;

  final ValueChanged<String> onChanged;

  const _BaseCurrencyPicker({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),

            const SizedBox(width: 8),

            Text('主货币', style: textTheme.titleMedium),
          ],
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _currencyOptions.map((option) {
                final selected = option.code == value;

                return ChoiceChip(
                  label: Text(option.label),

                  selected: selected,

                  onSelected: enabled ? (_) => onChanged(option.code) : null,

                  backgroundColor: AppColors.coolMid.withValues(alpha: 0.06),

                  selectedColor: AppColors.coolMid.withValues(alpha: 0.13),

                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        selected ? AppColors.coolMid : AppColors.textSecondary,
                  ),

                  side: BorderSide(
                    color:
                        selected
                            ? AppColors.coolMid.withValues(alpha: 0.45)
                            : AppColors.coolDeep.withValues(alpha: 0.12),
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  showCheckmark: false,
                );
              }).toList(),
        ),

        const SizedBox(height: 8),

        Text('净资产、总资产等汇总都会以主货币展示', style: textTheme.bodySmall),
      ],
    );
  }
}
