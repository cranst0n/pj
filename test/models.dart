import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:pj/pj.dart';

class Foo extends Equatable {
  final int a;
  final bool b;

  const Foo(this.a, this.b);

  static Foo apply(int a, bool b) => Foo(a, b);

  static final decoder = Decoder.forProduct2(
    decodeAt('a', Decoder.integer).withDefault(42),
    decodeAt('b', Decoder.boolean),
    Foo.apply,
  );

  static final encoder = Encoder.forProduct2<Foo, int, bool>(
    encode('a', Encoder.integer),
    encode('b', Encoder.boolean),
    (foo) => tuple2(foo.a, foo.b),
  );

  @override
  List<Object?> get props => [a, b];

  static Foo gen() => Foo(
        Faker().randomGenerator.integer(999999),
        Faker().randomGenerator.boolean(),
      );
}

class Bar extends Equatable {
  final double a;
  final String b;

  const Bar(this.a, this.b);

  static Bar apply(double a, String b) => Bar(a, b);

  static final decoder = Decoder.forProduct2(
    decodeAt('a', Decoder.dubble),
    decodeAt('b', Decoder.string),
    Bar.apply,
  );

  static final encoder = Encoder.forProduct2<Bar, double, String>(
    encode('a', Encoder.dubble),
    encode('b', Encoder.string),
    (bar) => tuple2(bar.a, bar.b),
  );

  @override
  List<Object?> get props => [a, b];

  static Bar gen() => Bar(
        Faker().randomGenerator.decimal(),
        Faker().randomGenerator.string(1000),
      );
}

class Baz extends Equatable {
  final int integer;
  final Option<String> maybeString1;
  final Option<String> maybeString2;
  final double dubble;
  final bool boolean;
  final List<String> strings;
  final List<Foo> foos;
  final Bar bar;
  final List<bool> bools;
  final bool? nullable;
  final String recovered;
  final DateTime mary;
  final DateTime had;
  final int little;
  final int lamb;

  const Baz(
    this.integer,
    this.maybeString1,
    this.maybeString2,
    this.dubble,
    this.boolean,
    this.strings,
    this.foos,
    this.bar,
    this.bools,
    this.nullable,
    this.recovered,
    this.mary,
    this.had,
    this.little,
    this.lamb,
  );

  static Baz apply(
    int integer,
    Option<String> maybeString1,
    Option<String> maybeString2,
    double dubble,
    bool boolean,
    List<String> strings,
    List<Foo> foos,
    Bar bar,
    List<bool> bools,
    bool? nullable,
    String recovered,
    DateTime mary,
    DateTime had,
    int little,
    int lamb,
  ) =>
      Baz(integer, maybeString1, maybeString2, dubble, boolean, strings, foos,
          bar, bools, nullable, recovered, mary, had, little, lamb);

  static final decoder = Decoder.forProduct15(
    decodeInt('integer').ensure((x) => x > 0, 'int must be > 0'),
    decodeString('maybeString1').optional,
    decodeString('maybeString2').optional,
    decodeAt('dubble', Decoder.dubble),
    decodeAt('boolean', Decoder.boolean),
    decodeAt('strings', Decoder.list(Decoder.string)),
    decodeAt('foos', Decoder.list(Foo.decoder)),
    decodeAt('bar', Bar.decoder),
    decodeAt('bools', Decoder.list(Decoder.boolean)),
    decodeAt('nullable', Decoder.boolean).nullable,
    decodeAt('recovered', Decoder.string).recover('recovered!'),
    decodeAt('mary', Decoder.dateTime),
    decodeAt('had', Decoder.dateTime),
    decodeAt('little', Decoder.integer),
    decodeAt('lamb', Decoder.integer),
    Baz.apply,
  );

  static final encoder = Encoder.forProduct15<
      Baz,
      int,
      Option<String>,
      Option<String>,
      double,
      bool,
      List<String>,
      List<Foo>,
      Bar,
      List<bool>,
      bool?,
      String,
      DateTime,
      DateTime,
      int,
      int>(
    encode('integer', Encoder.integer),
    encode('maybeString1', Encoder.string.optional),
    encode('maybeString2', Encoder.string.optional),
    encode('dubble', Encoder.dubble),
    encode('boolean', Encoder.boolean),
    encode('strings', Encoder.list(Encoder.string)),
    encode('foos', Encoder.list(Foo.encoder)),
    encode('bar', Bar.encoder),
    encode('bools', Encoder.list(Encoder.boolean)),
    encode('nullable', Encoder.boolean),
    encode('recovered', Encoder.string),
    encode('mary', Encoder.dateTime),
    encode('had', Encoder.dateTime),
    encode('little', Encoder.integer),
    encode('lamb', Encoder.integer),
    (baz) => Tuple15(
      baz.integer,
      baz.maybeString1,
      baz.maybeString2,
      baz.dubble,
      baz.boolean,
      baz.strings,
      baz.foos,
      baz.bar,
      baz.bools,
      baz.nullable,
      baz.recovered,
      baz.mary,
      baz.had,
      baz.little,
      baz.lamb,
    ),
  );

  @override
  List<Object?> get props => [
        integer,
        maybeString1,
        maybeString2,
        dubble,
        boolean,
        strings,
        foos,
        bar,
        bools,
        nullable,
        recovered,
        mary,
        had,
        little,
        lamb,
      ];

  static Baz gen() => Baz(
        Faker().randomGenerator.integer(10000),
        some(Faker().randomGenerator.string(1000)),
        none<String>(),
        Faker().randomGenerator.decimal(),
        Faker().randomGenerator.boolean(),
        List.generate(100, (_) => Faker().randomGenerator.string(1000)),
        List.generate(100, (_) => Foo.gen()),
        Bar.gen(),
        List.generate(25, (_) => Faker().randomGenerator.boolean()),
        true,
        'recovered',
        DateTime.fromMillisecondsSinceEpoch(
            Faker().randomGenerator.integer(100000000)),
        DateTime.fromMillisecondsSinceEpoch(
            Faker().randomGenerator.integer(100000000)),
        Faker().randomGenerator.integer(100000000),
        Faker().randomGenerator.integer(100000000),
      );
}
