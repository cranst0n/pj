import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Encoder.boolean', () {
    expect(encodeBool('x').encode(true), {'x': true});
  });

  test('Encoder.dateTime', () {
    expect(
        encodeDateTime('x')
            .encode(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        {'x': '1970-01-01T00:00:00.000Z'});
  });

  test('Encoder.dubble', () {
    expect(encodeDouble('x').encode(1.23), {'x': 1.23});
  });

  test('Encoder.duration', () {
    expect(
        encodeDuration('x')
            .encode(const Duration(seconds: 1, milliseconds: 100)),
        {'x': 1100000});
  });

  test('Encoder.integer', () {
    expect(encodeInt('x').encode(42), {'x': 42});
  });

  test('Encoder.string', () {
    expect(encodeString('x').encode('hello'), {'x': 'hello'});
  });

  test('Encoder.bigint', () {
    expect(encodeBigInt('x').encode(BigInt.two), {'x': '2'});
  });

  test('Encoder.list', () {
    expect(encodeList('x', Encoder.string).encode(['hello', 'world']), {
      'x': ['hello', 'world']
    });
  });

  test('Encoder.ilist', () {
    expect(
        encodeIList('x', Encoder.string).encode(IList.from(['hello', 'world'])),
        {
          'x': ['hello', 'world']
        });
  });

  test('Encoder.optional', () {
    expect(encodeKey('x', Encoder.string.optional).encode(some('hello')),
        {'x': 'hello'});
    expect(encodeKey('x', Encoder.string.optional).encode(none()), {'x': null});
  });

  test('Encoder.nullable', () {
    expect(encodeKey('x', Encoder.string.nullable).encode('hello'),
        {'x': 'hello'});
    expect(encodeKey('x', Encoder.string.nullable).encode(null), {'x': null});
  });

  test('Encoder.either', () {
    final encoder = encodeKey('x', Encoder.string.either(Encoder.integer));

    expect(encoder.encode(right(42)), {'x': 42});
    expect(encoder.encode(left('hello')), {'x': 'hello'});
  });

  test('Encoder.contramap', () {
    expect(
      encodeInt('a').contramap<String>(int.parse).encode('42'),
      {'a': 42},
    );
  });

  test('Encoder.optional', () {
    expect(
      encodeInt('a').optional.encode(some(42)),
      {'a': 42},
    );

    expect(
      encodeInt('a').optional.encode(none()),
      {'a': null},
    );
  });

  test('Encoder.nullable', () {
    expect(
      encodeInt('a').nullable.encode(42),
      {'a': 42},
    );

    expect(
      encodeInt('a').nullable.encode(null),
      {'a': null},
    );
  });

  test('Encoder.keyed', () {
    expect(
        encodeKey('foo', Encoder.integer.keyed('key')).keyed('key2').encode(2),
        {
          'key2': {
            'foo': {'key': 2}
          }
        });

    expect(
        encodeKey('foo', Encoder.integer.keyed('key').keyed('key2')).encode(2),
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
      (err) => fail('Bar roundtrip decode should not fail: $err'),
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
      (err) => fail('List<DateTime> decode should not fail: $err'),
      (actual) => expect(actual, expected),
    );
  });

  test('Encoder.forProduct2', () {
    final encoder = Encoder.forProduct2(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple2(1, 2)),
      {'a': 1, 'b': 2},
    );
  });

  test('Encoder.forProduct3', () {
    final encoder = Encoder.forProduct3(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple3(1, 2, 3)),
      {'a': 1, 'b': 2, 'c': 3},
    );
  });

  test('Encoder.forProduct4', () {
    final encoder = Encoder.forProduct4(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple4(1, 2, 3, 4)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4},
    );
  });

  test('Encoder.forProduct5', () {
    final encoder = Encoder.forProduct5(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple5(1, 2, 3, 4, 5)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5},
    );
  });

  test('Encoder.forProduct6', () {
    final encoder = Encoder.forProduct6(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple6(1, 2, 3, 4, 5, 6)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6},
    );
  });

  test('Encoder.forProduct7', () {
    final encoder = Encoder.forProduct7(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple7(1, 2, 3, 4, 5, 6, 7)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7},
    );
  });

  test('Encoder.forProduct8', () {
    final encoder = Encoder.forProduct8(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple8(1, 2, 3, 4, 5, 6, 7, 8)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8},
    );
  });

  test('Encoder.forProduct9', () {
    final encoder = Encoder.forProduct9(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      id,
    );

    expect(
      encoder.encode(tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9},
    );
  });

  test('Encoder.forProduct10', () {
    final encoder = Encoder.forProduct10(
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
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
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
      encodeKey('k', Encoder.integer),
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
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
      encodeKey('k', Encoder.integer),
      encodeKey('l', Encoder.integer),
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
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
      encodeKey('k', Encoder.integer),
      encodeKey('l', Encoder.integer),
      encodeKey('m', Encoder.integer),
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
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
      encodeKey('k', Encoder.integer),
      encodeKey('l', Encoder.integer),
      encodeKey('m', Encoder.integer),
      encodeKey('n', Encoder.integer),
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
      encodeKey('a', Encoder.integer),
      encodeKey('b', Encoder.integer),
      encodeKey('c', Encoder.integer),
      encodeKey('d', Encoder.integer),
      encodeKey('e', Encoder.integer),
      encodeKey('f', Encoder.integer),
      encodeKey('g', Encoder.integer),
      encodeKey('h', Encoder.integer),
      encodeKey('i', Encoder.integer),
      encodeKey('j', Encoder.integer),
      encodeKey('k', Encoder.integer),
      encodeKey('l', Encoder.integer),
      encodeKey('m', Encoder.integer),
      encodeKey('n', Encoder.integer),
      encodeKey('o', Encoder.integer),
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
