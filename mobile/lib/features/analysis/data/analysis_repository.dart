import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/analysis_overview.dart';

class AnalysisRepository {
  final ApiClient _apiClient;

  AnalysisRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  Future<AnalysisOverview> getAnalysis() async {
    final response = await _apiClient.get(
      ApiEndpoints.analysis,
    );

    return AnalysisOverview.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}