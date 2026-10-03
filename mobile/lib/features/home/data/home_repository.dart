import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/home_overview.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<HomeOverview> getOverview() async {
    final response = await _apiClient.get(ApiEndpoints.homeOverview);

    // 成功体是 {code, message, data} 外壳，HomeOverview 只需要 data。
    return HomeOverview.fromJson(ApiClient.unwrapMap(response));
  }
}
