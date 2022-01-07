import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Decoder.boolean', () {
    _primitiveTest(decodeBool('x'), {'x': true}, true);
    _primitiveTest(decodeBool('x'), {'x': false}, false);
  });

  test('Decoder.dubble', () {
    _primitiveTest(decodeDouble('x'), {'x': 1.234}, 1.234);
    _primitiveTest(decodeDouble('x'), {'x': -9.87}, -9.87);
  });

  test('Decoder.integer', () {
    _primitiveTest(decodeInt('x'), {'x': 1234}, 1234);
    _primitiveTest(decodeInt('x'), {'x': -987}, -987);
  });

  test('Decoder.number', () {
    _primitiveTest(decodeNum('x'), {'x': 1234}, 1234);
    _primitiveTest(decodeNum('x'), {'x': -987.65}, -987.65);
  });

  test('Decoder.string', () {
    _primitiveTest(decodeString('x'), {'x': 'hello'}, 'hello');
  });

  test('Decoder.bigint', () {
    _primitiveTest(decodeBigInt('x'), {'x': '1'}, BigInt.one);
    _primitiveTest(decodeBigInt('x'), {'x': '-135790'}, BigInt.from(-135790));

    expect(
      decodeBigInt('x').decode({'x': '-Q13'}),
      left<DecodingError, BigInt>(
          DecodingError.parsingFailure('Could not parse BigInt: -Q13')),
    );
  });

  test('Decoder.object', () {
    _primitiveTest(decodeObject('x'), {
      'x': {'foo': 1, 'bar': true}
    }, {
      'foo': 1,
      'bar': true
    });
  });

  test('Decoder.dateTime', () {
    _primitiveTest(decodeDateTime('x'), {'x': '2021-11-17T12:25:38.790927'},
        DateTime.parse('2021-11-17T12:25:38.790927'));
  });

  test('Decoder.duration', () {
    _primitiveTest(decodeDuration('x'), {'x': 35500000},
        const Duration(seconds: 35, milliseconds: 500));
  });

  test('Decoder.ilist', () {
    _primitiveTest(
        decodeIList('x', Decoder.string),
        {
          'x': ['a', 'b', 'c']
        },
        IList.from(['a', 'b', 'c']));
  });

  test('Decoder.list', () {
    _primitiveTest(decodeList('x', Decoder.integer), {
      'x': [0, 1, 2]
    }, [
      0,
      1,
      2
    ]);
  });

  test('Decoder.lift', () {
    Decoder.lift(right(42)).decode(['x', 'y', 'z']).fold(
      (err) => fail('Decoder lifting right should not fail: $err'),
      (actual) => expect(actual, 42),
    );
  });

  test('Decoder.fail', () {
    Decoder.fail<int>('foo').decode({'x': 1}).fold(
        (err) => expect(err, const DecodingError('foo')),
        (actual) => fail('Decoder.fail should not succeed: $actual'));
  });

  test('Decoder.as', () {
    decodeKey('x', Decoder.integer.as(42)).decode({'x': 0}).fold(
      (err) => fail('Decoder.as should not fail: $err'),
      (actual) => expect(actual, 42),
    );
  });

  test('Decoder.emap', () {
    Either<String, int> foo(int i) => i > 0 ? right(42) : left('emap left');

    Decoder.integer.emap(foo).decode(1).fold(
        (err) => fail('emap left should not fail: $err'),
        (actual) => expect(actual, 42));

    Decoder.integer.emap(foo).decode(-1).fold(
        (err) => expect(err, const DecodingError('emap left')),
        (actual) => fail('emap right should not succeed: $actual'));
  });

  test('Decoder.omap', () {
    Option<int> foo(String s) => s.isNotEmpty ? some(42) : none();

    Decoder.string.omap(foo, () => 'foo none').decode('non-empty').fold(
        (err) => fail('omap none should not fail: $err'),
        (actual) => expect(actual, 42));

    Decoder.string.omap(foo, () => 'foo none').decode('').fold(
        (err) => expect(err, const DecodingError('foo none')),
        (actual) => fail('omap some should not succeed: $actual'));
  });

  test('Decoder.fold', () {
    final decoder = decodeInt('x').fold((_) => 'left', (_) => 'right');

    decoder.decode({'x': 0}).fold(
      (err) => fail('fold should not fail: $err'),
      (actual) => expect(actual, 'right'),
    );

    decoder.decode({'x': bool}).fold(
      (err) => fail('fold should not fail: $err'),
      (actual) => expect(actual, 'left'),
    );
  });

  test('Decoder.handleError', () {
    decodeInt('x').handleError((_) => 24).decode({'x': 'string'}).fold(
      (err) => fail('handleError should not fail: $err'),
      (actual) => expect(actual, 24),
    );

    decodeInt('x').handleError((_) => 24).decode({'x': 42}).fold(
      (err) => fail('handleError should not fail: $err'),
      (actual) => expect(actual, 42),
    );
  });

  test('Decoder.handleErrorWith', () {
    Decoder<int> handler(DecodingError error) {
      if (error is MissingFieldFailure) {
        return Decoder.fail('Unrecoverable');
      } else {
        return Decoder.pure(123);
      }
    }

    decodeInt('x').handleErrorWith(handler).decode({'x': 'str'}).fold(
      (err) => fail('handleErrorWith error should not fail: $err'),
      (actual) => expect(actual, 123),
    );

    decodeInt('x').handleErrorWith(handler).decode({'y': 'str'}).fold(
      (err) => expect(err, const DecodingError('Unrecoverable')),
      (actual) => fail('handleErrorWith success failed: $actual'),
    );
  });

  test('Decoder.optional', () {
    Decoder.integer.keyed('x').optional.decode({'x': null}).fold(
      (err) => fail('optional null should not fail: $err'),
      (actual) => expect(actual, none<int>()),
    );

    // Ensure that the placement of the '.optional' doesn't matter
    Decoder.integer.optional.keyed('x').decode({'x': null}).fold(
      (err) => fail('optional null should not fail: $err'),
      (actual) => expect(actual, none<int>()),
    );
  });

  test('Decoder.nullable', () {
    Decoder.integer.keyed('x').nullable.decode({'x': null}).fold(
      (err) => fail('nullable null should not fail: $err'),
      (actual) => expect(actual, null),
    );

    // Ensure that the placement of the '.nullable' doesn't matter
    Decoder.integer.nullable.keyed('x').decode({'x': null}).fold(
      (err) => fail('nullable null should not fail: $err'),
      (actual) => expect(actual, null),
    );
  });

  test('Decoder.either', () {
    final decoder = decodeKey('x', Decoder.integer.either(Decoder.boolean));

    decoder.decode({'x': 42}).fold(
      (err) => fail('either error should not fail: $err'),
      (actual) => expect(actual, left<int, bool>(42)),
    );

    decoder.decode({'x': false}).fold(
      (err) => fail('either error should not fail: $err'),
      (actual) => expect(actual, right<int, bool>(false)),
    );
  });

  test('Decoder.either behavior', () {
    final encoder = encodeInt('a').either(encodeString('a'));

    expect(encoder.encode(left(42)), {'a': 42});
    expect(encoder.encode(right('foo')), {'a': 'foo'});

    expect(
      decodeInt('a')
          .either(decodeString('a'))
          .decode(encoder.encode(right('42'))),
      right<DecodingError, Either<int, String>>(right('42')),
    );
  });

  test('Decoder.withErrorMessage', () {
    decodeKey('x', Decoder.boolean)
        .withErrorMessage('fubar')
        .decode({'y': 123}).fold(
      (err) => expect(err.reason, 'fubar'),
      (actual) => fail('withEitherMesage error should not succeed: $actual'),
    );
  });

  test('Decoder.at (fail)', () {
    decodeKey('x', Decoder.boolean).decode([true, false, true]).fold(
      (err) => expect(err, const DecodingError("Expected value at field: 'x'")),
      (actual) => fail('at error should not succeed: $actual'),
    );
  });

  test('Decode Baz', () {
    final test = {
      'integer': 1,
      'maybeString2': 'hello',
      'dubble': 3.45,
      'boolean': true,
      'strings': ['a', 'b', 'c'],
      'foos': [
        {'a': 1, 'b': true},
        {'a': 2, 'b': false}
      ],
      'bar': {
        'a': 7.0,
        'b': 'message',
      },
      'bools': [true, false, false],
      'recovered': 1.23, // double field expected to be a string
      'mary': '1970-01-01 00:00:10.000Z',
      'had': '1970-01-01 00:00:50.000Z',
      'little': 42,
      'lamb': -42,
    };

    Baz.codec.decode(test).fold(
          (err) => fail('Baz object decode should not fail: $err'),
          (baz) => expect(
            baz,
            Baz(
                1,
                none(),
                some('hello'),
                3.45,
                true,
                const ['a', 'b', 'c'],
                const [Foo(1, true), Foo(2, false)],
                const Bar(7.0, 'message'),
                const [true, false, false],
                null,
                'recovered!',
                DateTime.fromMillisecondsSinceEpoch(10000, isUtc: true),
                DateTime.fromMillisecondsSinceEpoch(50000, isUtc: true),
                42,
                -42),
          ),
        );
  });

  test('Decode List<Foo>', () {
    final testJson = [
      {'a': 1, 'b': true},
      {'b': false},
      {'a': 3, 'b': false},
    ];

    Codec.list(Foo.codec).decode(testJson).fold(
          (err) => fail('List<Foo> decode should not fail: $err'),
          (actual) => expect(
            actual,
            const [Foo(1, true), Foo(42, false), Foo(3, false)],
          ),
        );
  });

  test('Decode List<Foo> (from string)', () {
    const str = '[{"a":1, "b":false}, {"a":2, "b":true}]';
    final json = jsonDecode(str);

    Codec.list(Foo.codec).decode(json).fold(
          (err) => fail('Foo list decode should not fail: $err'),
          (fooList) => expect(fooList, const [Foo(1, false), Foo(2, true)]),
        );
  });
}

void _primitiveTest<A>(Decoder<A> decoder, dynamic json, A expected) {
  decoder
      .decode(json)
      .fold((err) => fail(err.reason), (actual) => expect(actual, expected));
}
