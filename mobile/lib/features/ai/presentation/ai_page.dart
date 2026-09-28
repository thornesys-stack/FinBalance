import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'AI\n\n交易分类、转账识别、风险提醒、财务建议将在这里统一呈现。',
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
