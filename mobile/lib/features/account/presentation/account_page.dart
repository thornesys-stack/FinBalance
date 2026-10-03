import 'package:flutter/material.dart';

import '../../../core/domain/account/asset_summary.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/account_repository.dart';
import 'widgets/profile_card.dart';

class AccountPage extends StatefulWidget {
  final AccountRepository accountRepository;

  /// 账户页是登出口的所在地，因此需要认证状态。
  final AuthController authController;

  const AccountPage({
    super.key,
    required this.accountRepository,
    required this.authController,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = true;

  AssetSummary? _assetSummary;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await widget.accountRepository.getAssetSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        _assetSummary = summary;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = '暂时无法加载账户数据';
      });
    }
  }

  /// 退出登录。
  ///
  /// 必须二次确认：这是不可撤销的操作（token 会被后端吊销），
  /// 放在账户页最底部时很容易被误触。
  ///
  /// 确认后不需要任何导航 —— [AuthGate] 监听到状态变化后
  /// 会把整棵子树换成登录页。
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder:
          (dialogContext) => AlertDialog(
            title: const Text('退出登录'),

            content: const Text('退出后需要重新输入邮箱和密码才能查看数据。'),

            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),

                child: const Text('取消'),
              ),

              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),

                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expense,
                ),

                child: const Text('退出'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await widget.authController.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账户')),

      body: AnimatedBuilder(
        animation: widget.authController,

        builder:
            (context, _) => RefreshIndicator(
              onRefresh: _loadAccountData,

              child: _buildBody(),
            ),
      ),
    );
  }

  // Body
  Widget _buildBody() {
    // 身份卡片始终在最上面，且**不依赖**资产数据是否加载成功 ——
    // 否则后端一挂，用户连"退出登录"都点不到，只能卸载 App。
    final header = ProfileCard(
      user: widget.authController.user,

      notice: widget.authController.notice,

      isLoggingOut: widget.authController.isSubmitting,

      onLogout: _confirmLogout,
    );

    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16),

        children: [
          header,

          const SizedBox(height: 60),

          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16),

        children: [
          header,

          const SizedBox(height: 60),

          Center(
            child: Column(
              children: [
                const Icon(Icons.account_balance_outlined, size: 48),

                const SizedBox(height: 16),

                Text(_errorMessage!),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: _loadAccountData,

                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final summary = _assetSummary;

    if (summary == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16),

        children: [
          header,

          const SizedBox(height: 40),

          const Center(child: Text('暂无账户数据')),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.all(16),

      children: [
        header,

        const SizedBox(height: 20),

        _MoneySection(
          title: '总资产',
          values: summary.totalAssetsByCurrency,
          icon: Icons.account_balance_wallet_outlined,
        ),

        const SizedBox(height: 16),

        _MoneySection(
          title: '总负债',
          values: summary.totalLiabilitiesByCurrency,
          icon: Icons.credit_card_outlined,
        ),

        const SizedBox(height: 16),

        _MoneySection(
          title: '净资产',
          values: summary.netWorthByCurrency,
          icon: Icons.savings_outlined,
        ),
      ],
    );
  }
}

// Money Section
class _MoneySection extends StatelessWidget {
  final String title;

  final Map<String, Money> values;

  final IconData icon;

  const _MoneySection({
    required this.title,
    required this.values,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return _EmptyMoneySection(title: title, icon: icon);
    }

    final entries = values.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),

        const SizedBox(height: 10),

        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssetCard(title: entry.key, value: entry.value),
          ),
        ),
      ],
    );
  }
}

// Asset Card
class _AssetCard extends StatelessWidget {
  final String title;

  final Money value;

  const _AssetCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final currency = value.currency;

    final amount = _minorToMajor(value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: 8),

            Text(
              _formatMoney(value, amount),
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 4),

            Text(currency.name, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  double _minorToMajor(Money money) {
    var divisor = 1;

    for (var i = 0; i < money.currency.decimalDigits; i++) {
      divisor *= 10;
    }

    return money.amountMinor / divisor;
  }

  String _formatMoney(Money money, double amount) {
    return '${money.currency.symbol}'
        '${amount.toStringAsFixed(money.currency.decimalDigits)}';
  }
}

// Empty Section
class _EmptyMoneySection extends StatelessWidget {
  final String title;

  final IconData icon;

  const _EmptyMoneySection({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),

        const SizedBox(height: 10),

        const Card(
          child: Padding(padding: EdgeInsets.all(20), child: Text('暂无数据')),
        ),
      ],
    );
  }
}
