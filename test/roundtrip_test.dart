import 'package:faker/faker.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Roundtrip List<Bar>', () {
    final original = List.generate(100, (_) => Bar.gen());

    final decoded = Decoder.list(Bar.decoder)
        .decode(Encoder.list(Bar.encoder).encode(original));

    decoded.fold(
      (err) => fail('Bar roundtrip failed: $err'),
      (actual) => expect(actual, original),
    );
  });

  test('Roundtrip List<DateTime>', () {
    final expected = List.generate(
      100,
      (_) => DateTime.fromMillisecondsSinceEpoch(
          Faker().randomGenerator.integer(100000000)),
    );

    final decodedString = Decoder.list(Decoder.dateTime)
        .decode(Encoder.list(Encoder.dateTime).encode(expected));

    decodedString.fold(
      (err) => fail('List<DateTime> decode failed: $err'),
      (actual) => expect(actual, expected),
    );
  });

  test('Roundtrip Baz', () {
    final baz = Baz.gen();

    Baz.decoder.decode(Baz.encoder.encode(baz)).fold(
          (err) => fail('Baz roundtrip failed: $err'),
          (actual) => expect(actual, baz),
        );
  });
}
