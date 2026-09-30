import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/transaction_response.dart';
import '../domain/transaction_summary.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  Future<TransactionResponse> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.transactions,
      queryParameters: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    return TransactionResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<TransactionSummary> getSummary() async {
    final response = await _apiClient.get(
      ApiEndpoints.transactionSummary,
    );

    return TransactionSummary.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}