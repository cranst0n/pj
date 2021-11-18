import 'package:equatable/equatable.dart';

class DecodingError extends Equatable {
  final String reason;

  const DecodingError(this.reason);

  static DecodingError apply(String reason) => DecodingError(reason);

  static DecodingError missingField(String label) =>
      MissingFieldFailure._('MissingFieldFailure $label');

  static DecodingError parsingFailure(String reason) =>
      ParsingFailure._('ParsingFailure: $reason');

  DecodingError withReason(String reason) => DecodingError(reason);

  @override
  List<Object?> get props => [reason];
}

class MissingFieldFailure extends DecodingError {
  const MissingFieldFailure._(String reason) : super(reason);

  @override
  DecodingError withReason(String reason) => MissingFieldFailure._(reason);
}

class ParsingFailure extends DecodingError {
  const ParsingFailure._(String reason) : super(reason);

  @override
  DecodingError withReason(String reason) => ParsingFailure._(reason);
}
