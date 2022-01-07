import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pj/pj.dart';

// ignore_for_file: avoid_positional_boolean_parameters

class Foo extends Equatable {
  final int a;
  final bool b;

  const Foo(this.a, this.b);

  static Foo apply(int a, bool b) => Foo(a, b);

  static final codec = Codec.forProduct2(
    codecInt('a').withDefault(42),
    codecBool('b'),
    Foo.apply,
    (f) => tuple2(f.a, f.b),
  );

  @override
  List<Object?> get props => [a, b];
}

class Bar extends Equatable {
  final double a;
  final String b;

  const Bar(this.a, this.b);

  static Bar apply(double a, String b) => Bar(a, b);

  static final codec = Codec.forProduct2(
    codecDouble('a'),
    codecString('b'),
    Bar.apply,
    (b) => tuple2(b.a, b.b),
  );

  @override
  List<Object?> get props => [a, b];
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
  final Map<String, dynamic> mary;
  final DateTime had;
  final Duration little;
  final BigInt lamb;

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
    Map<String, dynamic> mary,
    DateTime had,
    Duration little,
    BigInt lamb,
  ) =>
      Baz(integer, maybeString1, maybeString2, dubble, boolean, strings, foos,
          bar, bools, nullable, recovered, mary, had, little, lamb);

  static final codec = Codec.forProduct15(
    codecInt('integer').ensure((x) => x > 0, 'int must be > 0'),
    codecString('maybeString1').optional,
    codecString('maybeString2').optional,
    codecDouble('dubble'),
    codecBool('boolean'),
    codecList('strings', Codec.string),
    codecList('foos', Foo.codec),
    codecKeyed('bar', Bar.codec),
    codecList('bools', Codec.boolean),
    codecKeyed('nullable', Codec.boolean).nullable,
    codecString('recovered').recover('recovered!'),
    codecObject('mary'),
    codecDateTime('had'),
    codecDuration('little'),
    codecBigInt('lamb'),
    Baz.apply,
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
}
