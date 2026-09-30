import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/account_repository.dart';
import '../domain/asset_summary.dart';
import '../domain/financial_account.dart';
import '../domain/user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() =>
      _AccountPageState();
}

class _AccountPageState
    extends State<AccountPage> {
  final AccountRepository _repository =
      AccountRepository();

  late Future<_AccountData> _futureData;

  @override
  void initState() {
    super.initState();

    _futureData = _loadData();
  }

  Future<_AccountData> _loadData() async {
    final results = await Future.wait([
      _repository.getCurrentUser(),
      _repository.getAccounts(),
      _repository.getAssetSummary(),
    ]);

    return _AccountData(
      user: results[0] as User,
      accounts:
          results[1] as List<FinancialAccount>,
      summary: results[2] as AssetSummary,
    );
  }

  void _reload() {
    setState(() {
      _futureData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_AccountData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: _reload,
                child: const Text('重新加载'),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text('暂无账户信息'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '我的',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    data.user.name,
                  ),
                  subtitle: Text(
                    data.user.email,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '净资产',
                        style: TextStyle(
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(
                          data.summary.netAssets,
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '账户',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...data.accounts.map(
                (account) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    title: Text(account.name),
                    subtitle: Text(account.type),
                    trailing: Text(
                      CurrencyFormatter.format(
                        account.balance,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountData {
  final User user;
  final List<FinancialAccount> accounts;
  final AssetSummary summary;

  const _AccountData({
    required this.user,
    required this.accounts,
    required this.summary,
  });
}