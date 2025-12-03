class EventMetadata {
  final int sourcePlayerId;
  final DateTime timestamp;
  final bool isChildEvent;

  EventMetadata({
    required this.sourcePlayerId,
    DateTime? timestamp,
    this.isChildEvent = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory EventMetadata.now({
    required int sourcePlayerId,
    bool isChildEvent = false,
  }) {
    return EventMetadata(
      sourcePlayerId: sourcePlayerId,
      isChildEvent: isChildEvent,
    );
  }

  EventMetadata copyWith({
    int? sourcePlayerId,
    DateTime? timestamp,
    bool? isChildEvent,
  }) {
    return EventMetadata(
      sourcePlayerId: sourcePlayerId ?? this.sourcePlayerId,
      timestamp: timestamp ?? this.timestamp,
      isChildEvent: isChildEvent ?? this.isChildEvent,
    );
  }
}
