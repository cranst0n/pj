import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'arbitraries.dart';
import 'models.dart';

void main() {
  test('Codec.boolean', () {
    _codecTest(Codec.boolean.keyed('foo'), true);
    _codecTest(Codec.boolean.keyed('foo'), false);
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
