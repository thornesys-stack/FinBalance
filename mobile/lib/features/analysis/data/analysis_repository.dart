import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/analysis_overview.dart';

class AnalysisRepository {
  final ApiClient _apiClient;

  AnalysisRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<AnalysisOverview> getAnalysis() async {
    // 后端路径是 /analysis/overview [V1.1 §28]；旧的 /analysis 是 404。
    final response = await _apiClient.get(ApiEndpoints.analysisOverview);

    return AnalysisOverview.fromJson(ApiClient.unwrapMap(response));
  }
}
