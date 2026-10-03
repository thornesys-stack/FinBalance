// FinBalance 金融账户状态。
// 用于描述账户当前是否可以正常使用。
enum AccountStatus {
  // 正常。
  active,
  // 暂停。
  suspended,
  // 已关闭。
  closed,
  // 已删除。
  deleted,
  // 状态未知。
  unknown,
}
