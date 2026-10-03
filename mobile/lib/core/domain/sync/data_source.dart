// FinBalance 金融数据来源。
// 用于描述一笔金融数据来自哪里。
enum DataSource {
  // 手动录入。
  manual,
  // 微信。
  wechat,
  // 支付宝。
  alipay,
  // 银行。
  bank,
  // 信用卡。
  creditCard,
  // 投资平台。
  investmentPlatform,
  // 文件导入。
  fileImport,
  // API 同步。
  api,
  // 其他来源。
  other,
  // 未知来源。
  unknown,
}
