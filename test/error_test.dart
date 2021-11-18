import 'package:pj/pj.dart';
import 'package:test/test.dart';

void main() {
  test('DecodingError.withReason', () {
    expect(DecodingError.apply('foo').withReason('bar').reason, 'bar');
    expect(DecodingError.missingField('foo').withReason('bar').reason, 'bar');
    expect(DecodingError.parsingFailure('foo').withReason('bar').reason, 'bar');
  });
}
