import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  double _balance = 0;
  double _income = 0;
  double _expense = 0;

  String _startDate = '';
  String _endDate = '';

  String _aiSummary = '正在生成本期财务摘要……';

  final Map<String, _CategoryData> _categories = {
    '餐饮': const _CategoryData(
      amount: 0,
      percentage: 0,
      progress: 0,
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFF4385F5),
      iconBackground: Color(0xFFE3F0FF),
    ),
    '购物': const _CategoryData(
      amount: 0,
      percentage: 0,
      progress: 0,
      icon: Icons.shopping_bag_rounded,
      iconColor: Color(0xFF725CE6),
      iconBackground: Color(0xFFEDE9FF),
    ),
    '交通': const _CategoryData(
      amount: 0,
      percentage: 0,
      progress: 0,
      icon: Icons.directions_car_rounded,
      iconColor: Color(0xFF2897E6),
      iconBackground: Color(0xFFE0F3FF),
    ),
    '娱乐': const _CategoryData(
      amount: 0,
      percentage: 0,
      progress: 0,
      icon: Icons.movie_rounded,
      iconColor: Color(0xFF2BAFA2),
      iconBackground: Color(0xFFE2F8F4),
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = ApiService();
      final response = await _apiService.getHomeOverview();

      if (!mounted) return;

      _parseHomeData(response);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '暂时无法获取财务数据';
      });

      debugPrint('Home API Error: $e');
    }
  }

  void _parseHomeData(dynamic response) {
    /*
     * 兼容常见 FastAPI 返回结构：
     *
     * {
     *   "balance": 4270,
     *   "income": 8500,
     *   "expense": 4230,
     *   "period": {
     *     "startDate": "2026/08/19",
     *     "endDate": "2026/09/17"
     *   },
     *   "categories": [
     *     {
     *       "name": "餐饮",
     *       "amount": 1280,
     *       "percentage": 30.3
     *     }
     *   ],
     *   "aiSummary": "本期消费整体较为稳定……"
     * }
     */

    final Map<String, dynamic> data;

    if (response is Map<String, dynamic>) {
      data = response;
    } else {
      throw Exception('Home API 返回的数据格式错误');
    }

    _balance = _toDouble(data['balance']);
    _income = _toDouble(data['income']);
    _expense = _toDouble(data['expense']);

    final dynamic period = data['period'];

    if (period is Map<String, dynamic>) {
      _startDate =
          period['startDate']?.toString() ??
          period['start_date']?.toString() ??
          '';

      _endDate =
          period['endDate']?.toString() ??
          period['end_date']?.toString() ??
          '';
    }

    final dynamic summary =
        data['aiSummary'] ??
        data['ai_summary'] ??
        data['summary'];

    if (summary != null && summary.toString().trim().isNotEmpty) {
      _aiSummary = summary.toString();
    }

    final dynamic categories = data['categories'];

    if (categories is List) {
      for (final item in categories) {
        if (item is! Map) continue;

        final String name =
            item['name']?.toString() ??
            item['category']?.toString() ??
            '';

        if (!_categories.containsKey(name)) continue;

        final double amount = _toDouble(item['amount']);

        final double percentage = _toDouble(
          item['percentage'] ??
              item['percent'],
        );

        final double progress = percentage > 1
            ? (percentage / 100).clamp(0.0, 1.0)
            : percentage.clamp(0.0, 1.0);

        final old = _categories[name]!;

        _categories[name] = _CategoryData(
          amount: amount,
          percentage: percentage,
          progress: progress,
          icon: old.icon,
          iconColor: old.iconColor,
          iconBackground: old.iconBackground,
        );
      }
    } else if (categories is Map) {
      /*
       * 同时兼容：
       *
       * "categories": {
       *   "餐饮": {
       *      "amount": 1280,
       *      "percentage": 30.3
       *   }
       * }
       */

      categories.forEach((key, value) {
        final String name = key.toString();

        if (!_categories.containsKey(name)) return;

        if (value is! Map) return;

        final double amount = _toDouble(value['amount']);

        final double percentage = _toDouble(
          value['percentage'] ??
              value['percent'],
        );

        final double progress = percentage > 1
            ? (percentage / 100).clamp(0.0, 1.0)
            : percentage.clamp(0.0, 1.0);

        final old = _categories[name]!;

        _categories[name] = _CategoryData(
          amount: amount,
          percentage: percentage,
          progress: progress,
          icon: old.icon,
          iconColor: old.iconColor,
          iconBackground: old.iconBackground,
        );
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(double value) {
    return '¥${value.toStringAsFixed(2)}';
  }

  String _percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  String _periodText() {
    if (_startDate.isEmpty && _endDate.isEmpty) {
      return '暂无统计周期';
    }

    if (_startDate.isEmpty) {
      return _endDate;
    }

    if (_endDate.isEmpty) {
      return _startDate;
    }

    return '$_startDate ~ $_endDate';
  }

  _CategoryData _category(String name) {
    return _categories[name] ??
        const _CategoryData(
          amount: 0,
          percentage: 0,
          progress: 0,
          icon: Icons.category_rounded,
          iconColor: Color(0xFF4385F5),
          iconBackground: Color(0xFFE3F0FF),
        );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          28,
          8,
          28,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本期财务概览',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
                height: 1.15,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              _periodText(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF98A2B3),
              ),
            ),

            const SizedBox(height: 18),

            _buildBalanceCard(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMoneyCard(
                    title: '收入',
                    amount: _money(_income),
                    icon: Icons.arrow_downward_rounded,
                    iconColor: const Color(0xFF2DB9A5),
                    iconBackground: const Color(0xFFE5FAF6),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _buildMoneyCard(
                    title: '支出',
                    amount: _money(_expense),
                    icon: Icons.arrow_upward_rounded,
                    iconColor: const Color(0xFFFF5D7A),
                    iconBackground: const Color(0xFFFFEAF0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              '消费分类',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),

            const SizedBox(height: 13),

            _buildCategory(
              '餐饮',
            ),

            const SizedBox(height: 10),

            _buildCategory(
              '购物',
            ),

            const SizedBox(height: 10),

            _buildCategory(
              '交通',
            ),

            const SizedBox(height: 10),

            _buildCategory(
              '娱乐',
            ),

            const SizedBox(height: 30),

            const Text(
              'AI 财务摘要',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),

            const SizedBox(height: 13),

            _buildAiCard(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 14),

              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ),
            ],

            if (_isLoading) ...[
              const SizedBox(height: 14),

              const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String name) {
    final category = _category(name);

    return _buildCategoryItem(
      icon: category.icon,
      name: name,
      amount: _money(category.amount),
      percentage: _percentage(category.percentage),
      progress: category.progress,
      iconColor: category.iconColor,
      iconBackground: category.iconBackground,
    );
  }

  // 本期结余
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      height: 124,
      padding: const EdgeInsets.fromLTRB(
        22,
        15,
        22,
        14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF3157E8),
            Color(0xFF6383F1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3157E8).withValues(
              alpha: 0.18,
            ),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本期结余',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            _money(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            _isLoading
                ? '正在计算……'
                : '本期收入减去本期支出',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.82,
              ),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 收入 / 支出
  Widget _buildMoneyCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          height: 112,
          padding: const EdgeInsets.fromLTRB(
            17,
            10,
            17,
            10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.78,
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.9,
              ),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF98A2B3),
                ),
              ),

              const SizedBox(height: 1),

              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 消费分类
  Widget _buildCategoryItem({
    required IconData icon,
    required String name,
    required String amount,
    required String percentage,
    required double progress,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 76,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.88,
              ),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF182230),
                      ),
                    ),

                    const SizedBox(height: 5),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 5,
                            width: double.infinity,
                            color: const Color(
                              0xFFDCE7F6,
                            ),
                          ),

                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 5,
                              decoration:
                                  BoxDecoration(
                                color: iconColor,
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '占支出 $percentage',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB0BAC9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),

              const SizedBox(width: 3),

              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF91A4C7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AI 财务摘要
  Widget _buildAiCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 124,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFFE9EFFF,
            ).withValues(
              alpha: 0.76,
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.85,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF5276E8),
                  size: 21,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  _aiSummary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Color(0xFF34456D),
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF91A4C7),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  final double amount;
  final double percentage;
  final double progress;

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _CategoryData({
    required this.amount,
    required this.percentage,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}