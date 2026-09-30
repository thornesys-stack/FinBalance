import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/asset_summary.dart';
import '../domain/financial_account.dart';
import '../domain/user.dart';

class AccountRepository {
  final ApiClient _apiClient;

  AccountRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(
      ApiEndpoints.currentUser,
    );

    return User.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<List<FinancialAccount>> getAccounts() async {
    final response = await _apiClient.get(
      ApiEndpoints.accounts,
    );

    final list = response is List
        ? response
        : response['items'] as List? ?? [];

    return list
        .map(
          (item) => FinancialAccount.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<AssetSummary> getAssetSummary() async {
    final response = await _apiClient.get(
      ApiEndpoints.assetSummary,
    );

    return AssetSummary.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}