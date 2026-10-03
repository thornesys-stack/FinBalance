// FinBalance 数据同步状态。
// 用于描述当前数据源或账户同步任务的状态。
enum SyncStatus {
  // 尚未同步。
  notSynced,
  // 正在同步。
  syncing,
  // 最近一次同步成功。
  success,
  // 同步失败。
  failed,
  // 授权已失效。
  authorizationExpired,
  // 状态未知。
  unknown,
}
