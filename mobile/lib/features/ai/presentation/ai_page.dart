import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/ai_repository.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final AiRepository _repository = AiRepository();

  final TextEditingController _controller =
      TextEditingController();

  String? _response;

  bool _loading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _loading) {
      return;
    }

    setState(() {
      _loading = true;
      _response = null;
    });

    try {
      final result =
          await _repository.sendMessage(message);

      if (!mounted) {
        return;
      }

      setState(() {
        _response = result.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _response = '请求失败：$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'AI 财务助手',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '让 AI 帮你理解自己的财务状况',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _response ??
                          '你可以询问收入、支出、预算、异常消费等问题。',
                      style: const TextStyle(
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '输入你的财务问题...',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton.filled(
                  onPressed:
                      _loading ? null : _sendMessage,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}