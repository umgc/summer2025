class ConnectionRequestResponse {
  final String? message;
  final int? requestId;
  final String? error;

  ConnectionRequestResponse({this.message, this.requestId, this.error});

  factory ConnectionRequestResponse.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestResponse(
      message: json['message'],
      requestId: json['requestId'],
      error: json['error'],
    );
  }

  bool get isSuccess => requestId != null && error == null;
}
