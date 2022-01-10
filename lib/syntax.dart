import 'package:dartz/dartz.dart';
import 'package:pj/src/codec.dart';

extension CodecStringOps on String {
  Codec<BigInt> get bigInt => Codec.bigint.keyed(this);

  Codec<bool> get boolean => Codec.boolean.keyed(this);

  Codec<DateTime> get dateTime => Codec.dateTime.keyed(this);

  Codec<double> get dubble => Codec.dubble.keyed(this);

  Codec<Duration> get duration => Codec.duration.keyed(this);

  Codec<IList<A>> ilistOf<A>(Codec<A> elementCodec) =>
      Codec.ilistOf(elementCodec).keyed(this);

  Codec<int> get integer => Codec.integer.keyed(this);

  Codec<List<A>> listOf<A>(Codec<A> elementCodec) =>
      Codec.listOf(elementCodec).keyed(this);

  Codec<num> get number => Codec.number.keyed(this);

  Codec<A> of<A>(Codec<A> codec) => codec.keyed(this);

  Codec<Map<String, dynamic>> get object => Codec.object.keyed(this);

  Codec<String> get string => Codec.string.keyed(this);
}

Codec<BigInt> Function(String s) get bigInt => (key) => key.bigInt;

Codec<bool> Function(String s) get boolean => (key) => key.boolean;

Codec<DateTime> Function(String s) get dateTime => (key) => key.dateTime;

Codec<double> Function(String s) get dubble => (key) => key.dubble;

Codec<Duration> Function(String s) get duration => (key) => key.duration;

Codec<IList<A>> Function(String s) ilistOf<A>(Codec<A> elementCodec) =>
    (key) => key.ilistOf(elementCodec);

Codec<int> Function(String s) get integer => (key) => key.integer;

Codec<List<A>> Function(String s) listOf<A>(Codec<A> elementCodec) =>
    (key) => key.listOf(elementCodec);

Codec<num> Function(String s) get number => (key) => key.number;

Codec<Map<String, dynamic>> Function(String s) get object =>
    (key) => key.object;

Codec<String> Function(String s) get string => (key) => key.string;
