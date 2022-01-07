import 'package:pj/pj.dart';
import 'package:test/test.dart';

void main() {
  test('DecodingError.withReason', () {
    expect(DecodingError.apply('foo').withReason('bar').reason, 'bar');
    expect(DecodingError.missingField('foo').withReason('bar').reason, 'bar');
    expect(DecodingError.parsingFailure('foo').withReason('bar').reason, 'bar');
  });

  test('DecodingError.hashcode equality', () {
    expect(
      DecodingError.missingField('1234567890').hashCode,
      DecodingError.missingField('1234567890').hashCode,
    );
  });

  test('DecodingError.toString() equality', () {
    expect(
      const DecodingError('i messed up.').toString(),
      const DecodingError('i messed up.').toString(),
    );
  });

  test('MissingField.toString() equality', () {
    expect(
      DecodingError.missingField('Miss u.').toString(),
      DecodingError.missingField('Miss u.').toString(),
    );
  });

  test('ParsingError.toString() equality', () {
    expect(
      DecodingError.parsingFailure('Parsnippity!').toString(),
      DecodingError.parsingFailure('Parsnippity!').toString(),
    );
  });
}
