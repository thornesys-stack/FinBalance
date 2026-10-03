class AiResponse {
  final String message;

  const AiResponse({required this.message});

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      message:
          json['message']?.toString() ?? json['response']?.toString() ?? '',
    );
  }
}
