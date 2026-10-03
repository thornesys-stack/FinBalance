class AccountConnection {
  final String id;
  final String provider;
  final String status;
  final DateTime? connectedAt;

  const AccountConnection({
    required this.id,
    required this.provider,
    required this.status,
    this.connectedAt,
  });

  factory AccountConnection.fromJson(Map<String, dynamic> json) {
    return AccountConnection(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      connectedAt: _parseDate(json['connected_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
