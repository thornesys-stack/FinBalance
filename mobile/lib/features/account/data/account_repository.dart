import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/domain/account/asset_summary.dart';
import '../../../core/domain/account/financial_account.dart';
import '../domain/user.dart';
import 'account_mapper.dart';

class AccountRepository {
  final ApiClient _apiClient;

  AccountRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.userProfile);

    // GET /api/v1/user 的 data 是 `{user: {...}, data_summary: {...}}`：
    // 身份本身嵌套在 user 键下，data_summary 是删除数据前的提示用统计。
    final data = ApiClient.unwrapMap(response);
    final user = data['user'];

    return User.fromJson(user is Map ? Map<String, dynamic>.from(user) : data);
  }

  Future<List<FinancialAccount>> getAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.accounts);

    // GET /api/v1/accounts 的 data 是
    // `{accounts: [...], updated_at: ..., total: N}` [V1.1 §11]。
    final data = ApiClient.unwrap(response);
    final list = data is List ? data : (data is Map ? data['accounts'] : null);

    if (list is! List) {
      return const [];
    }

    return list
        .whereType<Map>()
        .map(
          (item) => AccountMapper.financialAccountFromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<AssetSummary> getAssetSummary() async {
    // 后端路径是 /accounts/overview [V1.1 §21]；旧的 /accounts/summary 是 404。
    final response = await _apiClient.get(ApiEndpoints.accountOverview);

    return AccountMapper.assetSummaryFromJson(ApiClient.unwrapMap(response));
  }
}
