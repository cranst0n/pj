import 'package:faker/faker.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'arbitraries.dart';
import 'models.dart';

void main() {
  test('Roundtrip List<Bar>', () {
    final original = List.generate(100, (_) => Arbitraries.bar());
    final codec = Codec.listOf(Bar.codec);

    final decoded = codec.decode(codec.encode(original));

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

    final decodedString = Decoder.listOf(Decoder.dateTime)
        .decode(Encoder.listOf(Encoder.dateTime).encode(expected));

    decodedString.fold(
      (err) => fail('List<DateTime> decode failed: $err'),
      (actual) => expect(actual, expected),
    );
  });

  test('Roundtrip Baz', () {
    final baz = Arbitraries.baz();

    Baz.codec.decode(Baz.codec.encode(baz)).fold(
          (err) => fail('Baz roundtrip failed: $err'),
          (actual) => expect(actual, baz),
        );
  });
}
