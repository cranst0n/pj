import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:pj/syntax.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  test('Decoder.boolean', () {
    _primitiveTest(boolean('x').decoder, {'x': true}, true);
    _primitiveTest(boolean('x').decoder, {'x': false}, false);
  });

  test('Decoder.dubble', () {
    _primitiveTest(dubble('x').decoder, {'x': 1.234}, 1.234);
    _primitiveTest(dubble('x').decoder, {'x': -9.87}, -9.87);
  });

  test('Decoder.integer', () {
    _primitiveTest(integer('x').decoder, {'x': 1234}, 1234);
    _primitiveTest(integer('x').decoder, {'x': -987}, -987);
  });

  test('Decoder.number', () {
    _primitiveTest(number('x').decoder, {'x': 1234}, 1234);
    _primitiveTest(number('x').decoder, {'x': -987.65}, -987.65);
  });

  test('Decoder.string', () {
    _primitiveTest(string('x').decoder, {'x': 'hello'}, 'hello');
  });

  test('Decoder.bigint', () {
    _primitiveTest(bigInt('x').decoder, {'x': '1'}, BigInt.one);
    _primitiveTest(bigInt('x').decoder, {'x': '-135790'}, BigInt.from(-135790));

    expect(
      bigInt('x').decode({'x': '-Q13'}),
      left<DecodingError, BigInt>(
          DecodingError.parsingFailure('Could not parse BigInt: -Q13')),
    );
  });

  test('Decoder.object', () {
    _primitiveTest(object('obj').decoder, {
      'obj': {'foo': 1, 'bar': true}
    }, {
      'foo': 1,
      'bar': true
    });
  });

  test('Decoder.dateTime', () {
    _primitiveTest(dateTime('x').decoder, {'x': '2021-11-17T12:25:38.790927'},
        DateTime.parse('2021-11-17T12:25:38.790927'));
  });

  test('Decoder.duration', () {
    _primitiveTest(duration('x').decoder, {'x': 35500000},
        const Duration(seconds: 35, milliseconds: 500));
  });

  test('Decoder.ilist', () {
    _primitiveTest(
        ilistOf(Codec.string)('x').decoder,
        {
          'x': ['a', 'b', 'c']
        },
        IList.from(['a', 'b', 'c']));
  });

  test('Decoder.list', () {
    _primitiveTest(listOf(Codec.integer)('x').decoder, {
      'x': [0, 1, 2]
    }, [
      0,
      1,
      2
    ]);
  });

  test('Decoder.list with keyed decoder', overridePrint(() {
    final decoder = listOf(string('bar'))('foo').decoder;

    decoder.decode(['a', 'b', 'c']).fold(
      (err) {
        // Make sure the warning is given
        expect(printLog, [
          'warn: Passing a keyed (bar) decoder to an [i]List decoder.',
        ]);
        expect(err, const DecodingError("Expected value at field: 'foo'"));
      },
      (list) => fail('this should not happen!'),
    );
  }));

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
    integer('x').decoder.as(42).decode({'x': 0}).fold(
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
    final decoder = integer('x').decoder.fold((_) => 'left', (_) => 'right');

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
    integer('x').decoder.handleError((_) => 24).decode({'x': 'string'}).fold(
      (err) => fail('handleError should not fail: $err'),
      (actual) => expect(actual, 24),
    );

    integer('x').decoder.handleError((_) => 24).decode({'x': 42}).fold(
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

    integer('x').decoder.handleErrorWith(handler).decode({'x': 'str'}).fold(
      (err) => fail('handleErrorWith error should not fail: $err'),
      (actual) => expect(actual, 123),
    );

    integer('x').decoder.handleErrorWith(handler).decode({'y': 'str'}).fold(
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
    final decoder = Decoder.integer.either(Decoder.boolean).keyed('x');

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
    final encoder =
        Encoder.integer.keyed('a').either(Encoder.string.keyed('a'));

    expect(encoder.encode(left(42)), {'a': 42});
    expect(encoder.encode(right('foo')), {'a': 'foo'});

    expect(
      integer('a')
          .decoder
          .either(string('a').decoder)
          .decode(encoder.encode(right('42'))),
      right<DecodingError, Either<int, String>>(right('42')),
    );
  });

  test('Decoder.withErrorMessage', () {
    'x'.of(Codec.boolean).withErrorMessage('fubar').decode({'y': 123}).fold(
      (err) => expect(err.reason, 'fubar'),
      (actual) => fail('withEitherMesage error should not succeed: $actual'),
    );
  });

  test('Decoder.at (fail)', () {
    'x'.of(Codec.boolean).decode([true, false, true]).fold(
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
      'mary': {
        'a': 123,
        'b': 'abc',
        'c': true,
      },
      'had': '1970-01-01 00:00:50.000Z',
      'little': 1234567890,
      'lamb': "-42",
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
                const {'a': 123, 'b': 'abc', 'c': true},
                DateTime.fromMillisecondsSinceEpoch(50000, isUtc: true),
                const Duration(microseconds: 1234567890),
                BigInt.parse("-42")),
          ),
        );
  });

  test('Decode List<Foo>', () {
    final testJson = [
      {'a': 1, 'b': true},
      {'b': false},
      {'a': 3, 'b': false},
    ];

    Codec.listOf(Foo.codec).decode(testJson).fold(
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

    Codec.listOf(Foo.codec).decode(json).fold(
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

final printLog = [];

void Function() overridePrint(void Function() testFn) => () {
      final spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };
