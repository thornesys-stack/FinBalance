import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '分析\n\n资产趋势、收支结构与消费分析。',
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
