import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/phone_country.dart';

/// 弹出区号选择器，返回用户选中的地区；直接关闭则返回 null。
Future<PhoneCountry?> showPhoneCountryPicker(
  BuildContext context, {
  required PhoneCountry selected,
}) {
  return showModalBottomSheet<PhoneCountry>(
    context: context,

    backgroundColor: AppColors.surface,

    // 内容可能超过半屏，交给下面的高度约束处理，不用 bottom sheet 自己的
    // 默认比例（默认最高约半屏，13 个地区能滚但列表底部会贴着圆角）。
    isScrollControlled: true,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),

    builder: (sheetContext) => _PhoneCountrySheet(selected: selected),
  );
}

class _PhoneCountrySheet extends StatelessWidget {
  final PhoneCountry selected;

  const _PhoneCountrySheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部的小横条：给用户一个"这是可以下滑关掉的弹层"的暗示。
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),

            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),

            child: Row(
              children: [
                Text(
                  '选择国家 / 地区',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,

              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 8,
              ),

              itemCount: PhoneCountry.all.length,

              separatorBuilder:
                  (context, index) => const Divider(height: 1, indent: 20),

              itemBuilder: (context, index) {
                final country = PhoneCountry.all[index];

                // 用 isoCode 判定而不是对象比较：列表里都是 const 实例，
                // 但调用方传进来的可能来自别处（例如反序列化），
                // 比较 isoCode 是唯一稳定的口径。
                final isSelected = country.isoCode == selected.isoCode;

                return ListTile(
                  onTap: () => Navigator.of(context).pop(country),

                  title: Text(
                    country.name,

                    style: TextStyle(
                      fontSize: 14.5,

                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,

                      color:
                          isSelected
                              ? AppColors.coolMid
                              : AppColors.textPrimary,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,

                        style: TextStyle(
                          fontSize: 14,

                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,

                          color:
                              isSelected
                                  ? AppColors.coolMid
                                  : AppColors.textSecondary,
                        ),
                      ),

                      if (isSelected) ...[
                        const SizedBox(width: 8),

                        const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.coolMid,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
