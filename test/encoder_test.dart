import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:pj/syntax.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Encoder.boolean', () {
    expect('x'.boolean.encode(true), {'x': true});
  });

  test('Encoder.dateTime', () {
    expect(
        'x'
            .dateTime
            .encode(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        {'x': '1970-01-01T00:00:00.000Z'});
  });

  test('Encoder.dubble', () {
    expect('x'.dubble.encode(1.23), {'x': 1.23});
  });

  test('Encoder.duration', () {
    expect('x'.duration.encode(const Duration(seconds: 1, milliseconds: 100)),
        {'x': 1100000});
  });

  test('Encoder.integer', () {
    expect('x'.integer.encode(42), {'x': 42});
  });

  test('Encoder.number', () {
    expect('x'.number.encode(42), {'x': 42});
    expect('x'.number.encode(-76.54), {'x': -76.54});
  });

  test('Encoder.object', () {
    final object = {
      'a': 1,
      'b': {'c': 2}
    };

    expect('x'.object.encode(object), {'x': object});
  });

  test('Encoder.string', () {
    expect('x'.string.encode('hello'), {'x': 'hello'});
  });

  test('Encoder.bigint', () {
    expect('x'.bigInt.encode(BigInt.two), {'x': '2'});
  });

  test('Encoder.list', () {
    expect('x'.listOf(Codec.string).encode(['hello', 'world']), {
      'x': ['hello', 'world']
    });
  });

  test('Encoder.ilist', () {
    expect('x'.ilistOf(Codec.string).encode(IList.from(['hello', 'world'])), {
      'x': ['hello', 'world']
    });
  });

  test('Encoder.optional', () {
    expect('x'.string.optional.encode(some('hello')), {'x': 'hello'});
    expect('x'.string.optional.encode(none()), {'x': null});
  });

  test('Encoder.nullable', () {
    expect('x'.string.nullable.encode('hello'), {'x': 'hello'});
    expect('x'.string.nullable.encode(null), {'x': null});
  });

  test('Encoder.either', () {
    final encoder = 'x'.string.encoder.either('x'.integer.encoder);

    expect(encoder.encode(right(42)), {'x': 42});
    expect(encoder.encode(left('hello')), {'x': 'hello'});
  });

  test('Encoder.contramap', () {
    expect('a'.integer.encoder.contramap<String>(int.parse).encode('42'),
        {'a': 42});
  });

  test('Encoder.optional', () {
    expect('a'.integer.optional.encode(some(42)), {'a': 42});
    expect('a'.integer.optional.encode(none()), {'a': null});
  });

  test('Encoder.nullable', () {
    expect('a'.integer.nullable.encode(42), {'a': 42});
    expect('a'.integer.nullable.encode(null), {'a': null});
  });

  test('Encoder.keyed', () {
    expect('foo'.integer.at('key').at('key2').encode(2), {
      'key2': {
        'key': {'foo': 2}
      }
    });
  });

  test('Encoder.custom', () {
    final encoder = Encoder.custom((int i) => {
          'properties': {'name': 'Bruce', 'age': i}
        });
    expect(encoder.encode(42), {
      'properties': {'name': 'Bruce', 'age': 42}
    });
  });

  test('Encode Bar', () {
    const original = Bar(1.2, 'message');

    expect(Bar.codec.encode(original), {'a': 1.2, 'b': 'message'});
  });

  test('Encode List<Bar>', () {
    const original = [Bar(1.2, 's0'), Bar(3.4, 's1'), Bar(5.6, 's2')];

    final decoded = Decoder.listOf(Bar.codec.decoder)
        .decode(Encoder.listOf(Bar.codec.encoder).encode(original));

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

    final decoded = Decoder.listOf(Decoder.dateTime)
        .decode(Encoder.listOf(Encoder.dateTime).encode(expected));

    decoded.fold(
      (err) => fail('List<DateTime> decode should not fail: $err'),
      (actual) => expect(actual, expected),
    );
  });

  test('Encoder.forProduct2', () {
    final encoder = Encoder.forProduct2(
      'a'.integer.encoder,
      'b'.integer.encoder,
      id,
    );

    expect(encoder.encode(tuple2(1, 2)), {'a': 1, 'b': 2});
  });

  test('Encoder.forProduct3', () {
    final encoder = Encoder.forProduct3(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple3(1, 2, 3)),
      {'a': 1, 'b': 2, 'c': 3},
    );
  });

  test('Encoder.forProduct4', () {
    final encoder = Encoder.forProduct4(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple4(1, 2, 3, 4)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4},
    );
  });

  test('Encoder.forProduct5', () {
    final encoder = Encoder.forProduct5(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple5(1, 2, 3, 4, 5)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5},
    );
  });

  test('Encoder.forProduct6', () {
    final encoder = Encoder.forProduct6(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple6(1, 2, 3, 4, 5, 6)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6},
    );
  });

  test('Encoder.forProduct7', () {
    final encoder = Encoder.forProduct7(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple7(1, 2, 3, 4, 5, 6, 7)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7},
    );
  });

  test('Encoder.forProduct8', () {
    final encoder = Encoder.forProduct8(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple8(1, 2, 3, 4, 5, 6, 7, 8)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8},
    );
  });

  test('Encoder.forProduct9', () {
    final encoder = Encoder.forProduct9(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple9(1, 2, 3, 4, 5, 6, 7, 8, 9)),
      {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9},
    );
  });

  test('Encoder.forProduct10', () {
    final encoder = Encoder.forProduct10(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
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
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
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
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
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
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
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
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
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
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
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

  test('Encoder.forProduct16', () {
    final encoder = Encoder.forProduct16(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
      'p'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(
          tuple16(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)),
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
        'o': 15,
        'p': 16
      },
    );
  });

  test('Encoder.forProduct17', () {
    final encoder = Encoder.forProduct17(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
      'p'.integer.encoder,
      'q'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(
          tuple17(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)),
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
        'o': 15,
        'p': 16,
        'q': 17
      },
    );
  });

  test('Encoder.forProduct18', () {
    final encoder = Encoder.forProduct18(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
      'p'.integer.encoder,
      'q'.integer.encoder,
      'r'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple18(
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)),
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
        'o': 15,
        'p': 16,
        'q': 17,
        'r': 18
      },
    );
  });

  test('Encoder.forProduct19', () {
    final encoder = Encoder.forProduct19(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
      'p'.integer.encoder,
      'q'.integer.encoder,
      'r'.integer.encoder,
      's'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple19(
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)),
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
        'o': 15,
        'p': 16,
        'q': 17,
        'r': 18,
        's': 19
      },
    );
  });

  test('Encoder.forProduct20', () {
    final encoder = Encoder.forProduct20(
      'a'.integer.encoder,
      'b'.integer.encoder,
      'c'.integer.encoder,
      'd'.integer.encoder,
      'e'.integer.encoder,
      'f'.integer.encoder,
      'g'.integer.encoder,
      'h'.integer.encoder,
      'i'.integer.encoder,
      'j'.integer.encoder,
      'k'.integer.encoder,
      'l'.integer.encoder,
      'm'.integer.encoder,
      'n'.integer.encoder,
      'o'.integer.encoder,
      'p'.integer.encoder,
      'q'.integer.encoder,
      'r'.integer.encoder,
      's'.integer.encoder,
      't'.integer.encoder,
      id,
    );

    expect(
      encoder.encode(tuple20(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
          16, 17, 18, 19, 20)),
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
        'o': 15,
        'p': 16,
        'q': 17,
        'r': 18,
        's': 19,
        't': 20
      },
    );
  });
}
