import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:pj/syntax.dart';
import 'package:test/test.dart';

import 'arbitraries.dart';
import 'models.dart';

void main() {
  test('Codec.bigint', () {
    _codecTest(Codec.bigint, BigInt.one);
    _codecTest(Codec.bigint, BigInt.from(1234567890));
  });

  test('Codec.boolean', () {
    _codecTest(Codec.boolean, true);
    _codecTest(Codec.boolean, false);
  });

  test('Codec.dateTime', () {
    _codecTest(Codec.dateTime, DateTime.now());
    _codecTest(Codec.dateTime, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('Codec.dubble', () {
    _codecTest(Codec.dubble, 3.14);
    _codecTest(Codec.dubble, -8736.234);
  });

  test('Codec.duration', () {
    _codecTest(Codec.duration, Duration.zero);
    _codecTest(Codec.duration, const Duration(hours: 24));
  });

  test('Codec.xmap', () {
    final codec =
        Codec.string.xmap<bool>((s) => s.isNotEmpty, (b) => b ? 'xyz' : '');

    expect(codec.encode(false), '');
    expect(codec.encode(true), 'xyz');

    expect(codec.decode(''), right<DecodingError, bool>(false));
    expect(codec.decode('nonempty'), right<DecodingError, bool>(true));
  });

  test('Codec.exmap', () {
    Either<DecodingError, int> parseString(String s) =>
        optionOf(int.tryParse(s))
            .toEither(() => DecodingError('Failed to parse: $s'));

    final codec = string('foo').exmap<int>(parseString, (i) => i.toString());

    expect(codec.encode(42), {'foo': '42'});
    expect(codec.decode({'foo': '42'}), right<DecodingError, int>(42));
    expect(
        codec.decode({'foo': 'alpha'}),
        left<DecodingError, int>(
            const DecodingError('Failed to parse: alpha')));
  });

  test('Codec.recoverWith', () {
    final codec =
        Codec.integer.keyed('a').recoverWith(Codec.integer.keyed('b'));

    expect(codec.decode({'a': 1}), right<DecodingError, int>(1));
    expect(codec.decode({'b': 2}), right<DecodingError, int>(2));
    expect(codec.decode({'c': 3}),
        left<DecodingError, int>(DecodingError.missingField('b')));
  });

  test('Foo.codec', () {
    _codecTest(Foo.codec, Arbitraries.foo());
  });

  test('Codec.tuple2', () {
    _codecTest(
      Codec.tuple2(
        integer('a'),
        integer('b'),
      ),
      tuple2(1, 2),
    );
  });

  test('Codec.tuple3', () {
    _codecTest(
      Codec.tuple3(
        integer('a'),
        integer('b'),
        integer('c'),
      ),
      tuple3(1, 2, 3),
    );
  });

  test('Codec.tuple4', () {
    _codecTest(
      Codec.tuple4(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
      ),
      tuple4(1, 2, 3, 4),
    );
  });

  test('Codec.tuple5', () {
    _codecTest(
      Codec.tuple5(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
      ),
      tuple5(1, 2, 3, 4, 5),
    );
  });

  test('Codec.tuple6', () {
    _codecTest(
      Codec.tuple6(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
      ),
      tuple6(1, 2, 3, 4, 5, 6),
    );
  });

  test('Codec.tuple7', () {
    _codecTest(
      Codec.tuple7(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
      ),
      tuple7(1, 2, 3, 4, 5, 6, 7),
    );
  });

  test('Codec.tuple8', () {
    _codecTest(
      Codec.tuple8(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
      ),
      tuple8(1, 2, 3, 4, 5, 6, 7, 8),
    );
  });

  test('Codec.tuple9', () {
    _codecTest(
      Codec.tuple9(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
      ),
      tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9),
    );
  });

  test('Codec.tuple10', () {
    _codecTest(
      Codec.tuple10(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
      ),
      tuple10(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    );
  });

  test('Codec.tuple11', () {
    _codecTest(
      Codec.tuple11(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
      ),
      tuple11(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
    );
  });

  test('Codec.tuple12', () {
    _codecTest(
      Codec.tuple12(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
      ),
      tuple12(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),
    );
  });

  test('Codec.tuple13', () {
    _codecTest(
      Codec.tuple13(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
      ),
      tuple13(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13),
    );
  });

  test('Codec.tuple14', () {
    _codecTest(
      Codec.tuple14(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
      ),
      tuple14(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14),
    );
  });

  test('Codec.tuple15', () {
    _codecTest(
      Codec.tuple15(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
      ),
      tuple15(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
    );
  });

  test('Codec.tuple16', () {
    _codecTest(
      Codec.tuple16(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
        integer('p'),
      ),
      tuple16(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),
    );
  });

  test('Codec.tuple17', () {
    _codecTest(
      Codec.tuple17(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
        integer('p'),
        integer('q'),
      ),
      tuple17(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17),
    );
  });

  test('Codec.tuple18', () {
    _codecTest(
      Codec.tuple18(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
        integer('p'),
        integer('q'),
        integer('r'),
      ),
      tuple18(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18),
    );
  });

  test('Codec.tuple19', () {
    _codecTest(
      Codec.tuple19(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
        integer('p'),
        integer('q'),
        integer('r'),
        integer('s'),
      ),
      tuple19(
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19),
    );
  });

  test('Codec.tuple20', () {
    _codecTest(
      Codec.tuple20(
        integer('a'),
        integer('b'),
        integer('c'),
        integer('d'),
        integer('e'),
        integer('f'),
        integer('g'),
        integer('h'),
        integer('i'),
        integer('j'),
        integer('k'),
        integer('l'),
        integer('m'),
        integer('n'),
        integer('o'),
        integer('p'),
        integer('q'),
        integer('r'),
        integer('s'),
        integer('t'),
      ),
      tuple20(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20),
    );
  });

  test('Codec.forProduct2', () {
    _codecTest(
      Codec.forProduct2(
        'a'.integer,
        'b'.integer,
        (a, b) => tuple2(a, b),
        id,
      ),
      tuple2(1, 2),
    );
  });

  test('Codec.forProduct3', () {
    _codecTest(
      Codec.forProduct3(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        (a, b, c) => tuple3(a, b, c),
        id,
      ),
      tuple3(1, 2, 3),
    );
  });

  test('Codec.forProduct4', () {
    _codecTest(
      Codec.forProduct4(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        (a, b, c, d) => tuple4(a, b, c, d),
        id,
      ),
      tuple4(1, 2, 3, 4),
    );
  });

  test('Codec.forProduct5', () {
    _codecTest(
      Codec.forProduct5(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        (a, b, c, d, e) => tuple5(a, b, c, d, e),
        id,
      ),
      tuple5(1, 2, 3, 4, 5),
    );
  });

  test('Codec.forProduct6', () {
    _codecTest(
      Codec.forProduct6(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        (a, b, c, d, e, f) => tuple6(a, b, c, d, e, f),
        id,
      ),
      tuple6(1, 2, 3, 4, 5, 6),
    );
  });

  test('Codec.forProduct7', () {
    _codecTest(
      Codec.forProduct7(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        (a, b, c, d, e, f, g) => tuple7(a, b, c, d, e, f, g),
        id,
      ),
      tuple7(1, 2, 3, 4, 5, 6, 7),
    );
  });

  test('Codec.forProduct8', () {
    _codecTest(
      Codec.forProduct8(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        (a, b, c, d, e, f, g, h) => tuple8(a, b, c, d, e, f, g, h),
        id,
      ),
      tuple8(1, 2, 3, 4, 5, 6, 7, 8),
    );
  });

  test('Codec.forProduct9', () {
    _codecTest(
      Codec.forProduct9(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        (a, b, c, d, e, f, g, h, i) => tuple9(a, b, c, d, e, f, g, h, i),
        id,
      ),
      tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9),
    );
  });

  test('Codec.forProduct9', () {
    _codecTest(
      Codec.forProduct9(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        (a, b, c, d, e, f, g, h, i) => tuple9(a, b, c, d, e, f, g, h, i),
        id,
      ),
      tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9),
    );
  });

  test('Codec.forProduct10', () {
    _codecTest(
      Codec.forProduct10(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        (a, b, c, d, e, f, g, h, i, j) => tuple10(a, b, c, d, e, f, g, h, i, j),
        id,
      ),
      tuple10(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    );
  });

  test('Codec.forProduct11', () {
    _codecTest(
      Codec.forProduct11(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        (a, b, c, d, e, f, g, h, i, j, k) =>
            tuple11(a, b, c, d, e, f, g, h, i, j, k),
        id,
      ),
      tuple11(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
    );
  });

  test('Codec.forProduct12', () {
    _codecTest(
      Codec.forProduct12(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l) =>
            tuple12(a, b, c, d, e, f, g, h, i, j, k, l),
        id,
      ),
      tuple12(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),
    );
  });

  test('Codec.forProduct13', () {
    _codecTest(
      Codec.forProduct13(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m) =>
            tuple13(a, b, c, d, e, f, g, h, i, j, k, l, m),
        id,
      ),
      tuple13(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13),
    );
  });

  test('Codec.forProduct14', () {
    _codecTest(
      Codec.forProduct14(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n) =>
            tuple14(a, b, c, d, e, f, g, h, i, j, k, l, m, n),
        id,
      ),
      tuple14(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14),
    );
  });

  test('Codec.forProduct15', () {
    _codecTest(
      Codec.forProduct15(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o) =>
            tuple15(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o),
        id,
      ),
      tuple15(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
    );
  });

  test('Codec.forProduct16', () {
    _codecTest(
      Codec.forProduct16(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        'p'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) =>
            tuple16(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p),
        id,
      ),
      tuple16(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),
    );
  });

  test('Codec.forProduct17', () {
    _codecTest(
      Codec.forProduct17(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        'p'.integer,
        'q'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q) =>
            tuple17(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q),
        id,
      ),
      tuple17(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17),
    );
  });

  test('Codec.forProduct18', () {
    _codecTest(
      Codec.forProduct18(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        'p'.integer,
        'q'.integer,
        'r'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r) =>
            tuple18(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r),
        id,
      ),
      tuple18(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18),
    );
  });

  test('Codec.forProduct19', () {
    _codecTest(
      Codec.forProduct19(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        'p'.integer,
        'q'.integer,
        'r'.integer,
        's'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s) =>
            tuple19(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s),
        id,
      ),
      tuple19(
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19),
    );
  });

  test('Codec.forProduct20', () {
    _codecTest(
      Codec.forProduct20(
        'a'.integer,
        'b'.integer,
        'c'.integer,
        'd'.integer,
        'e'.integer,
        'f'.integer,
        'g'.integer,
        'h'.integer,
        'i'.integer,
        'j'.integer,
        'k'.integer,
        'l'.integer,
        'm'.integer,
        'n'.integer,
        'o'.integer,
        'p'.integer,
        'q'.integer,
        'r'.integer,
        's'.integer,
        't'.integer,
        (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t) =>
            tuple20(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t),
        id,
      ),
      tuple20(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20),
    );
  });
}

void _codecTest<A>(Codec<A> codec, A value) {
  codec.decode(codec.encode(value)).fold(
        (err) => fail('${codec.runtimeType} failed: $err'),
        (decoded) => expect(decoded, value),
      );
}
