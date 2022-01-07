class DecodingError {
  final String reason;

  const DecodingError(this.reason);

  static DecodingError apply(String reason) => DecodingError(reason);

  static DecodingError missingField(String key) => MissingFieldFailure._(key);

  static DecodingError parsingFailure(String reason) =>
      ParsingFailure._(reason);

  DecodingError withReason(String reason) => DecodingError(reason);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodingError &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => runtimeType.hashCode ^ reason.hashCode;

  @override
  String toString() => 'DecodingError: $reason';
}

class MissingFieldFailure extends DecodingError {
  const MissingFieldFailure._(String reason) : super(reason);

  @override
  DecodingError withReason(String reason) => MissingFieldFailure._(reason);

  @override
  String toString() => 'MissingFieldFailure: $reason';
}

class ParsingFailure extends DecodingError {
  const ParsingFailure._(String reason) : super(reason);

  @override
  DecodingError withReason(String reason) => ParsingFailure._(reason);

  @override
  String toString() => 'ParsingFailure: $reason';
}
