import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '账户\n\n账户连接、授权状态、多币种与同步设置。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF7D8799),
        ),
      ),
    );
  }
}
