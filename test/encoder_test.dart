import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Encode.boolean', () {
    expect(encodeBool('x').encode(true), {'x': true});
  });

  test('Encode.dateTime', () {
    expect(
        encodeDateTime('x')
            .encode(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        {'x': '1970-01-01T00:00:00.000Z'});
  });

  test('Encode.dubble', () {
    expect(encodeDouble('x').encode(1.23), {'x': 1.23});
  });

  test('Encode.duration', () {
    expect(
        encodeDuration('x')
            .encode(const Duration(seconds: 1, milliseconds: 100)),
        {'x': 1100000});
  });

  test('Encode.integer', () {
    expect(encodeInt('x').encode(42), {'x': 42});
  });

  test('Encode.string', () {
    expect(encodeString('x').encode('hello'), {'x': 'hello'});
  });

  test('Encode.bigint', () {
    expect(encodeBigInt('x').encode(BigInt.two), {'x': '2'});
  });

  test('Encode.list', () {
    expect(encodeList('x', Encoder.string).encode(['hello', 'world']), {
      'x': ['hello', 'world']
    });
  });

  test('Encode.ilist', () {
    expect(
        encodeIList('x', Encoder.string).encode(IList.from(['hello', 'world'])),
        {
          'x': ['hello', 'world']
        });
  });

  test('Encode.optional', () {
    expect(encodeAt('x', Encoder.string.optional).encode(some('hello')),
        {'x': 'hello'});
    expect(encodeAt('x', Encoder.string.optional).encode(none()), {'x': null});
  });

  test('Encode.nullable', () {
    expect(
        encodeAt('x', Encoder.string.nullable).encode('hello'), {'x': 'hello'});
    expect(encodeAt('x', Encoder.string.nullable).encode(null), {'x': null});
  });

  test('Encode.either', () {
    final encoder = encodeAt('x', Encoder.string.either(Encoder.integer));

    expect(encoder.encode(right(42)), {'x': 42});
    expect(encoder.encode(left('hello')), {'x': 'hello'});
  });

  test('LabeledEncoder.contramap', () {
    expect(
      encodeInt('a').contramap<String>(int.parse).encode('42'),
      {'a': 42},
    );
  });

  test('LabeledEncoder.optional', () {
    expect(
      encodeInt('a').optional.encode(some(42)),
      {'a': 42},
    );

    expect(
      encodeInt('a').optional.encode(none()),
      {'a': null},
    );
  });

  test('LabeledEncoder.nullable', () {
    expect(
      encodeInt('a').nullable.encode(42),
      {'a': 42},
    );

    expect(
      encodeInt('a').nullable.encode(null),
      {'a': null},
    );
  });

  test('LabeledEncoder.labeled', () {
    expect(
        encodeAt('foo', Encoder.integer.labeled('key'))
            .labeled('key2')
            .encode(2),
        {
          'key2': {
            'foo': {'key': 2}
          }
        });

    expect(
        encodeAt('foo', Encoder.integer.labeled('key').labeled('key2'))
            .encode(2),
        {
          'foo': {
            'key2': {'key': 2}
          }
        });
  });

  test('Encode Bar', () {
    const original = Bar(1.2, 'message');

    expect(Bar.codec.encode(original), {'a': 1.2, 'b': 'message'});
  });

  test('Encode List<Bar>', () {
    const original = [Bar(1.2, 's0'), Bar(3.4, 's1'), Bar(5.6, 's2')];

    final decoded = Decoder.list(Bar.codec.decoder)
        .decode(Encoder.list(Bar.codec.encoder).encode(original));

    decoded.fold(
      (err) => fail('Bar roundtrip decode failed: $err'),
      (actual) => expect(actual, original),
    );
  });

  test('Encode List<DateTime>', () {
    final expected = [
      DateTime.fromMillisecondsSinceEpoch(0),
      DateTime.fromMillisecondsSinceEpoch(1000),
    ];

    final decoded = Decoder.list(Decoder.dateTime)
        .decode(Encoder.list(Encoder.dateTime).encode(expected));

    decoded.fold(
      (err) => fail('List<DateTime> decode failed: $err'),
      (actual) => expect(actual, expected),
    );
  });

  test('Encoder.forProduct2', () {
    final encoder = Encoder.forProduct2(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple2(1, 2)),
      {'a': 1, 'b': 2},
    );
  });

  test('Encoder.forProduct3', () {
    final encoder = Encoder.forProduct3(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple3(1, 2, 3)),
      {'a': 1, 'b': 2, 'c': 3},
    );
  });

  test('Encoder.forProduct4', () {
    final encoder = Encoder.forProduct4(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple4(1, 2, 3, 4)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4},
    );
  });

  test('Encoder.forProduct5', () {
    final encoder = Encoder.forProduct5(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple5(1, 2, 3, 4, 5)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5},
    );
  });

  test('Encoder.forProduct6', () {
    final encoder = Encoder.forProduct6(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple6(1, 2, 3, 4, 5, 6)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6},
    );
  });

  test('Encoder.forProduct7', () {
    final encoder = Encoder.forProduct7(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple7(1, 2, 3, 4, 5, 6, 7)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7},
    );
  });

  test('Encoder.forProduct8', () {
    final encoder = Encoder.forProduct8(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple8(1, 2, 3, 4, 5, 6, 7, 8)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8},
    );
  });

  test('Encoder.forProduct9', () {
    final encoder = Encoder.forProduct9(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9},
    );
  });

  test('Encoder.forProduct10', () {
    final encoder = Encoder.forProduct10(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple10(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10
      },
    );
  });

  test('Encoder.forProduct11', () {
    final encoder = Encoder.forProduct11(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      encodeAt('k', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple11(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10,
        'k': 11
      },
    );
  });

  test('Encoder.forProduct12', () {
    final encoder = Encoder.forProduct12(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      encodeAt('k', Encoder.integer),
      encodeAt('l', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple12(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10,
        'k': 11,
        'l': 12
      },
    );
  });

  test('Encoder.forProduct13', () {
    final encoder = Encoder.forProduct13(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      encodeAt('k', Encoder.integer),
      encodeAt('l', Encoder.integer),
      encodeAt('m', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple13(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10,
        'k': 11,
        'l': 12,
        'm': 13
      },
    );
  });

  test('Encoder.forProduct14', () {
    final encoder = Encoder.forProduct14(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      encodeAt('k', Encoder.integer),
      encodeAt('l', Encoder.integer),
      encodeAt('m', Encoder.integer),
      encodeAt('n', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple14(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10,
        'k': 11,
        'l': 12,
        'm': 13,
        'n': 14
      },
    );
  });

  test('Encoder.forProduct15', () {
    final encoder = Encoder.forProduct15(
      encodeAt('a', Encoder.integer),
      encodeAt('b', Encoder.integer),
      encodeAt('c', Encoder.integer),
      encodeAt('d', Encoder.integer),
      encodeAt('e', Encoder.integer),
      encodeAt('f', Encoder.integer),
      encodeAt('g', Encoder.integer),
      encodeAt('h', Encoder.integer),
      encodeAt('i', Encoder.integer),
      encodeAt('j', Encoder.integer),
      encodeAt('k', Encoder.integer),
      encodeAt('l', Encoder.integer),
      encodeAt('m', Encoder.integer),
      encodeAt('n', Encoder.integer),
      encodeAt('o', Encoder.integer),
      id,
    );

    expect(
      encoder
          .encode(tuple15(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)),
      {
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
        'e': 5,
        'f': 6,
        'g': 7,
        'h': 8,
        'i': 9,
        'j': 10,
        'k': 11,
        'l': 12,
        'm': 13,
        'n': 14,
        'o': 15
      },
    );
  });
}
