import '../../../core/contracts/api_contracts.dart';
import '../../../core/network/api_client.dart';
import '../domain/home_overview.dart';

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HomeOverview> fetchOverview() async {
    final json = await _apiClient.get(ApiContracts.homeOverview);
    return HomeOverview.fromJson(json);
  }
}
