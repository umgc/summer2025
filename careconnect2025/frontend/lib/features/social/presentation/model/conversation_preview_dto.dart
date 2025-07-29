class ConversationPreviewDto {
  final int peerId;
  final String peerName;
  final String content; // last message
  final DateTime timestamp;

  ConversationPreviewDto({
    required this.peerId,
    required this.peerName,
    required this.content,
    required this.timestamp,
  });

  factory ConversationPreviewDto.fromJson(Map<String, dynamic> json) {
    return ConversationPreviewDto(
      peerId: json['peerId'],
      peerName: json['peerName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}