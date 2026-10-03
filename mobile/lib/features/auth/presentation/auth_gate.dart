import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';
import 'login_page.dart';
import 'register_page.dart';

/// 认证闸门 —— App 的根。
///
/// 为什么要在根部做分流，而不是在登录成功后 `push` 主界面：
///   登录态是全局的，而且会**被动**变化（refresh token 过期、401 自动登出）。
///   如果用 push/pop 管，就必须在每个可能失效的地方手动 pop 回登录页，
///   漏一处就会出现"已经登出但主界面还挂着"的状态。
///   把根节点绑到状态上之后，任何一次状态变化都会自动收敛到正确的界面。
class AuthGate extends StatefulWidget {
  final AuthController controller;

  /// 已登录时展示的界面（通常是 AppShell）。
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.controller,
    required this.authenticatedChild,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    // 放到首帧之后再触发：bootstrap 内部会读安全存储（平台通道调用），
    // 在 initState 里同步等待会白白拖慢第一帧。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        switch (widget.controller.status) {
          // 还没确认有没有登录态：既不能显示登录页（已登录用户会看到闪一下
          // 登录页），也不能直接进主界面（未登录时会看到闪一下主界面）。
          case AuthStatus.unknown:
            return const _SplashScreen();

          case AuthStatus.authenticated:
            return widget.authenticatedChild;

          case AuthStatus.unauthenticated:
            return _AuthFlow(controller: widget.controller);
        }
      },
    );
  }
}

/// 未登录时的登录 / 注册二选一。
///
/// 用内部标记切换而不是 Navigator：见 [AuthGate] 的说明。
/// 顺带避免了"返回键回到登录页"这种在认证流程里没有意义的回退。
class _AuthFlow extends StatefulWidget {
  final AuthController controller;

  const _AuthFlow({required this.controller});

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),

      // 默认的 FadeTransition 会让两张卡片在交叉时重叠成一个
      // 半透明的重影；加上轻微位移后方向感更清楚。
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },

      child:
          _showRegister
              ? RegisterPage(
                key: const ValueKey('register'),

                controller: widget.controller,

                onGoToLogin: () => setState(() => _showRegister = false),
              )
              : LoginPage(
                key: const ValueKey('login'),

                controller: widget.controller,

                onGoToRegister: () => setState(() => _showRegister = true),
              ),
    );
  }
}

/// 冷启动过渡页。
///
/// 通常只出现几毫秒（本地无凭证时）；只有凭证存在、需要打一次
/// `/auth/me` 的路径下才会明显可见。
///
/// 底色与登录页保持同一套浅冷渐变：两者之间只隔一次状态切换，
/// 底色不一致的话会出现一次明显的明暗跳变。
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backdropBase,

      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.authBackdropGradient,
        ),

        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 56,
                height: 56,

                decoration: BoxDecoration(
                  // 与登录页顶部的品牌标同一套语言：白玻璃 + 浅蓝描边 +
                  // 深冷色图标，让「冷启动 → 登录页」看起来是同一个界面的延续。
                  color: Colors.white.withValues(alpha: 0.72),

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: AppColors.coolBright.withValues(alpha: 0.30),
                  ),
                ),

                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.coolMid,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(
                width: 22,
                height: 22,

                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.coolMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
