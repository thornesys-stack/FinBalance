import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/ai_response.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AiResponse> sendMessage(String message) async {
    final response = await _apiClient.post(
      ApiEndpoints.aiChat,
      body: {'message': message},
    );

    // 必须取外壳里的 data：直接解析整包会把 envelope 的
    // "message": "success" 当成 AI 的回复内容显示出来。
    // data 形状：{conversation_id, message, created_at, provider, turns}。
    return AiResponse.fromJson(ApiClient.unwrapMap(response));
  }
}
