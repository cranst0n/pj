import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'arbitraries.dart';
import 'models.dart';

void main() {
  test('Codec.boolean', () {
    _codecTest(Codec.boolean.keyed('foo'), true);
    _codecTest(Codec.boolean.keyed('foo'), false);
  });

  test('Codec.xmap', () {
    final codec = Codec.string
        .xmap<bool>((s) => s.length > 0 ? true : false, (b) => b ? 'xyz' : '');

    expect(codec.encode(false), '');
    expect(codec.encode(true), 'xyz');

    expect(codec.decode(''), right<DecodingError, bool>(false));
    expect(codec.decode('nonempty'), right<DecodingError, bool>(true));
  });

  test('Codec.exmap', () {
    Either<String, int> parseString(String s) =>
        optionOf(int.tryParse(s)).toEither(() => 'Failed to parse: $s');

    final codec =
        codecString('foo').exmap<int>(parseString, (i) => i.toString());

    expect(codec.encode(42), {'foo': '42'});
    expect(codec.decode({'foo': '42'}), right<DecodingError, int>(42));
    expect(
        codec.decode({'foo': 'alpha'}),
        left<DecodingError, int>(
            const DecodingError('Failed to parse: alpha')));
  });

  test('Foo.codec', () {
    _codecTest(Foo.codec, Arbitraries.foo());
  });
}

void _codecTest<A>(Codec<A> codec, A value) {
  codec.decode(codec.encode(value)).fold(
        (err) => fail('Codec.boolean failed: $err'),
        (decoded) => expect(decoded, value),
      );
}
