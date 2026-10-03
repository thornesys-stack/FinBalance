/// 手机号国家 / 地区与区号。
///
/// 为什么需要这样一个列表而不是让用户直接输 `+86 138…`：
///   手机号是登录标识，同一串数字在不同区号下是不同的人。
///   把区号做成显式选择，能避免「用户以为输了完整号码、其实少了个 +86」
///   这种最常见的失败模式。
///
/// 列表只收录常用地区 —— 完整 E.164 有 200 多个区号，做成全量下拉会变成
/// 一场翻找。后端上线时若需要更多，在这里按同一结构追加即可。
class PhoneCountry {
  /// ISO 3166-1 alpha-2，例如 CN。用作稳定标识（名称可能被改）。
  final String isoCode;

  /// E.164 区号，含 `+`，例如 +86。
  final String dialCode;

  /// 展示名。
  ///
  /// 港澳台一律按中国口径书写，不写成独立国家。
  final String name;

  /// 该地区的本地号码位数；0 表示不固定（只做范围校验）。
  final int nationalLength;

  const PhoneCountry({
    required this.isoCode,
    required this.dialCode,
    required this.name,
    this.nationalLength = 0,
  });

  /// 顶部默认选项。
  static const PhoneCountry china = PhoneCountry(
    isoCode: 'CN',
    dialCode: '+86',
    name: '中国大陆',
    nationalLength: 11,
  );

  static const List<PhoneCountry> all = [
    china,
    PhoneCountry(
      isoCode: 'HK',
      dialCode: '+852',
      name: '中国香港',
      nationalLength: 8,
    ),
    PhoneCountry(
      isoCode: 'MO',
      dialCode: '+853',
      name: '中国澳门',
      nationalLength: 8,
    ),
    PhoneCountry(
      isoCode: 'TW',
      dialCode: '+886',
      name: '中国台湾',
      nationalLength: 9,
    ),
    PhoneCountry(
      isoCode: 'US',
      dialCode: '+1',
      name: '美国 / 加拿大',
      nationalLength: 10,
    ),
    PhoneCountry(isoCode: 'JP', dialCode: '+81', name: '日本'),
    PhoneCountry(isoCode: 'KR', dialCode: '+82', name: '韩国'),
    PhoneCountry(
      isoCode: 'SG',
      dialCode: '+65',
      name: '新加坡',
      nationalLength: 8,
    ),
    PhoneCountry(isoCode: 'MY', dialCode: '+60', name: '马来西亚'),
    PhoneCountry(isoCode: 'GB', dialCode: '+44', name: '英国'),
    PhoneCountry(
      isoCode: 'AU',
      dialCode: '+61',
      name: '澳大利亚',
      nationalLength: 9,
    ),
    PhoneCountry(isoCode: 'DE', dialCode: '+49', name: '德国'),
    PhoneCountry(isoCode: 'FR', dialCode: '+33', name: '法国'),
  ];

  /// 提交给后端的完整号码（E.164 去掉前导 `+` 之外的写法由后端定，
  /// 这里统一给 `+区号 + 本地号`，是最不容易产生歧义的形式）。
  String fullNumber(String nationalNumber) {
    final digits = nationalNumber.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$digits';
  }

  /// 去掉空格、括号、短横线等分隔符，只留数字。
  static String normalize(String raw) => raw.replaceAll(RegExp(r'\D'), '');
}
