import 'package:dartz/dartz.dart';
import 'package:faker/faker.dart';

import 'models.dart';

class Arbitraries {
  static final Faker _faker = Faker();

  static DateTime dateTime() => DateTime.fromMillisecondsSinceEpoch(
      _faker.randomGenerator.integer(100000000));

  static BigInt bigInt() => BigInt.from(integer());

  static bool boolean() => _faker.randomGenerator.boolean();

  static int integer() => _faker.randomGenerator.integer(999999);

  static String string() => _faker.randomGenerator.string(1000);

  static Foo foo() => Foo(
        integer(),
        boolean(),
      );

  static Bar bar() => Bar(
        _faker.randomGenerator.decimal(),
        string(),
      );

  static Baz baz() => Baz(
        integer(),
        some(string()),
        none<String>(),
        _faker.randomGenerator.decimal(),
        boolean(),
        List.generate(100, (_) => string()),
        List.generate(100, (_) => foo()),
        bar(),
        List.generate(25, (_) => boolean()),
        true,
        'recovered',
        {
          'a': integer(),
          'b': string(),
          'c': boolean(),
        },
        dateTime(),
        Duration(seconds: integer()),
        bigInt(),
      );
}
