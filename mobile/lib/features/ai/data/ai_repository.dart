import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/ai_response.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  Future<AiResponse> sendMessage(
    String message,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.aiChat,
      body: {
        'message': message,
      },
    );

    return AiResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}