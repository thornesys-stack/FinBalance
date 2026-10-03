import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../features/account/data/account_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/transaction/data/transaction_repository.dart';
import 'app_shell.dart';
import 'app_theme.dart';

/// App 根节点。
///
/// 改为 StatefulWidget 的目的只有一个：**依赖在 initState 里装一次**。
/// 在此之前每个 Repository 都在自己的构造函数里 `ApiClient()`，
/// 结果是 App 里同时存在 4 个 HTTP Client（也就有 4 份互相看不见的
/// access token），登录成功后业务请求依然不带 Authorization 头。
/// 这里用一个实例把认证与业务串起来。
class FinBalanceApp extends StatefulWidget {
  const FinBalanceApp({super.key});

  @override
  State<FinBalanceApp> createState() => _FinBalanceAppState();
}

class _FinBalanceAppState extends State<FinBalanceApp> {
  /// 全局唯一的 HTTP 出口 [架构 §49]。
  late final ApiClient _apiClient;

  late final AuthController _authController;

  late final AccountRepository _accountRepository;

  late final TransactionRepository _transactionRepository;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();

    _authController = AuthController(
      repository: AuthRepository(apiClient: _apiClient),
      apiClient: _apiClient,
    );

    _accountRepository = AccountRepository(apiClient: _apiClient);

    _transactionRepository = TransactionRepository(apiClient: _apiClient);
  }

  @override
  void dispose() {
    _authController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'FinBalance',

      theme: AppTheme.light,

      home: AuthGate(
        controller: _authController,

        authenticatedChild: AppShell(
          accountRepository: _accountRepository,

          transactionRepository: _transactionRepository,

          authController: _authController,
        ),
      ),
    );
  }
}
