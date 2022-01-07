import 'package:dartz/dartz.dart';

Encoder<A> encodeKey<A>(String key, Encoder<A> encoder) => encoder.keyed(key);

Encoder<BigInt> encodeBigInt(String key) => encodeKey(key, Encoder.bigint);

Encoder<bool> encodeBool(String key) => encodeKey(key, Encoder.boolean);

Encoder<DateTime> encodeDateTime(String key) =>
    encodeKey(key, Encoder.dateTime);

Encoder<double> encodeDouble(String key) => encodeKey(key, Encoder.dubble);

Encoder<Duration> encodeDuration(String key) =>
    encodeKey(key, Encoder.duration);

Encoder<int> encodeInt(String key) => encodeKey(key, Encoder.integer);

Encoder<IList<A>> encodeIList<A>(
  String key,
  Encoder<A> elementEncoder,
) =>
    encodeKey(key, Encoder.ilist(elementEncoder));

Encoder<List<A>> encodeList<A>(
  String key,
  Encoder<A> elementEncoder,
) =>
    encodeKey(key, Encoder.list(elementEncoder));

Encoder<num> encodeNum(String key) => encodeKey(key, Encoder.number);

Encoder<Map<String, dynamic>> encodeObject(String key) =>
    encodeKey(key, Encoder.object);

Encoder<String> encodeString(String key) => encodeKey(key, Encoder.string);

/// An [Encoder] provides the ability to convert from a type <A> to JSON.
class Encoder<A> {
  final Option<String> key;
  final dynamic Function(A) _encodeF;

  const Encoder._unkeyed(this._encodeF) : key = const None();

  const Encoder._keyed(this.key, this._encodeF);

  dynamic encode(A a) => key.fold<dynamic>(
        () => _encodeF(a),
        (key) => Map.fromEntries(
          [MapEntry(key, a != null ? _encodeF(a) : null)],
        ),
      );

  ///////////////////////////////// Primitives /////////////////////////////////

  static Encoder<BigInt> get bigint => string.contramap((bi) => bi.toString());
  static Encoder<bool> get boolean => _primitive<bool>();
  static Encoder<double> get dubble => _primitive<double>();
  static Encoder<int> get integer => _primitive<int>();
  static Encoder<num> get number => _primitive<num>();
  static Encoder<Map<String, dynamic>> get object =>
      _primitive<Map<String, dynamic>>();
  static Encoder<String> get string => _primitive<String>();

  static Encoder<DateTime> get dateTime =>
      string.contramap((dt) => dt.toIso8601String());

  static Encoder<Duration> get duration =>
      integer.contramap((d) => d.inMicroseconds);

  static Encoder<List<A>> list<A>(Encoder<A> elementEncoder) =>
      Encoder._unkeyed((list) => list.map(elementEncoder.encode).toList());

  static Encoder<IList<A>> ilist<A>(Encoder<A> elementEncoder) =>
      list(elementEncoder).contramap((il) => il.toList());

  static Encoder<T> _primitive<T>() => Encoder._unkeyed(id);

  //////////////////////////////// Combinators /////////////////////////////////

  Encoder<B> contramap<B>(A Function(B) f) =>
      Encoder._unkeyed((B b) => encode(f(b)));

  Encoder<Either<A, B>> either<B>(Encoder<B> encodeB) => Encoder._unkeyed(
      (either) => either.fold((a) => encode(a), (b) => encodeB.encode(b)));

  Encoder<A> keyed(String key) => Encoder._keyed(
      some(key), (a) => Encoder._keyed(this.key, _encodeF).encode(a));

  Encoder<A?> get nullable => Encoder._keyed(key, id);

  Encoder<Option<A>> get optional =>
      Encoder._keyed(key, (opt) => opt.fold(() => null, id));

  /////////////////////////////////// TupleN ///////////////////////////////////

  static Encoder<Tuple2<A, B>> tuple2<A, B>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
  ) =>
      Encoder._unkeyed((tuple) =>
          encodeA.encode(tuple.value1)..addAll(encodeB.encode(tuple.value2)));

  static Encoder<Tuple3<A, B, C>> tuple3<A, B, C>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
  ) =>
      Encoder._unkeyed((tuple) => tuple2(encodeA, encodeB).encode(tuple.init)
        ..addAll(encodeC.encode(tuple.last)));

  static Encoder<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
  ) =>
      Encoder._unkeyed((tuple) =>
          tuple3(encodeA, encodeB, encodeC).encode(tuple.init)
            ..addAll(encodeD.encode(tuple.last)));

  static Encoder<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
  ) =>
      Encoder._unkeyed((tuple) =>
          tuple4(encodeA, encodeB, encodeC, encodeD).encode(tuple.init)
            ..addAll(encodeE.encode(tuple.last)));

  static Encoder<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
  ) =>
      Encoder._unkeyed((tuple) =>
          tuple5(encodeA, encodeB, encodeC, encodeD, encodeE).encode(tuple.init)
            ..addAll(encodeF.encode(tuple.last)));

  static Encoder<Tuple7<A, B, C, D, E, F, G>> tuple7<A, B, C, D, E, F, G>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
  ) =>
      Encoder._unkeyed((tuple) =>
          tuple6(encodeA, encodeB, encodeC, encodeD, encodeE, encodeF)
              .encode(tuple.init)
            ..addAll(encodeG.encode(tuple.last)));

  static Encoder<Tuple8<A, B, C, D, E, F, G, H>> tuple8<A, B, C, D, E, F, G, H>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
  ) =>
      Encoder._unkeyed((tuple) =>
          tuple7(encodeA, encodeB, encodeC, encodeD, encodeE, encodeF, encodeG)
              .encode(tuple.init)
            ..addAll(encodeH.encode(tuple.last)));

  static Encoder<Tuple9<A, B, C, D, E, F, G, H, I>>
      tuple9<A, B, C, D, E, F, G, H, I>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
  ) =>
          Encoder._unkeyed((tuple) => tuple8(encodeA, encodeB, encodeC, encodeD,
                  encodeE, encodeF, encodeG, encodeH)
              .encode(tuple.init)
            ..addAll(encodeI.encode(tuple.last)));

  static Encoder<Tuple10<A, B, C, D, E, F, G, H, I, J>>
      tuple10<A, B, C, D, E, F, G, H, I, J>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
  ) =>
          Encoder._unkeyed((tuple) => tuple9(encodeA, encodeB, encodeC, encodeD,
                  encodeE, encodeF, encodeG, encodeH, encodeI)
              .encode(tuple.init)
            ..addAll(encodeJ.encode(tuple.last)));

  static Encoder<Tuple11<A, B, C, D, E, F, G, H, I, J, K>>
      tuple11<A, B, C, D, E, F, G, H, I, J, K>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
  ) =>
          Encoder._unkeyed((tuple) => tuple10(encodeA, encodeB, encodeC,
                  encodeD, encodeE, encodeF, encodeG, encodeH, encodeI, encodeJ)
              .encode(tuple.init)
            ..addAll(encodeK.encode(tuple.last)));

  static Encoder<Tuple12<A, B, C, D, E, F, G, H, I, J, K, L>>
      tuple12<A, B, C, D, E, F, G, H, I, J, K, L>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
  ) =>
          Encoder._unkeyed((tuple) => tuple11(
                  encodeA,
                  encodeB,
                  encodeC,
                  encodeD,
                  encodeE,
                  encodeF,
                  encodeG,
                  encodeH,
                  encodeI,
                  encodeJ,
                  encodeK)
              .encode(tuple.init)
            ..addAll(encodeL.encode(tuple.last)));

  static Encoder<Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>>
      tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
  ) =>
          Encoder._unkeyed((tuple) => tuple12(
                  encodeA,
                  encodeB,
                  encodeC,
                  encodeD,
                  encodeE,
                  encodeF,
                  encodeG,
                  encodeH,
                  encodeI,
                  encodeJ,
                  encodeK,
                  encodeL)
              .encode(tuple.init)
            ..addAll(encodeM.encode(tuple.last)));

  static Encoder<Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>>
      tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Encoder<N> encodeN,
  ) =>
          Encoder._unkeyed((tuple) => tuple13(
                  encodeA,
                  encodeB,
                  encodeC,
                  encodeD,
                  encodeE,
                  encodeF,
                  encodeG,
                  encodeH,
                  encodeI,
                  encodeJ,
                  encodeK,
                  encodeL,
                  encodeM)
              .encode(tuple.init)
            ..addAll(encodeN.encode(tuple.last)));

  static Encoder<Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>>
      tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Encoder<A> encodeA,
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Encoder<N> encodeN,
    Encoder<O> encodeO,
  ) =>
          Encoder._unkeyed((tuple) => tuple14(
                  encodeA,
                  encodeB,
                  encodeC,
                  encodeD,
                  encodeE,
                  encodeF,
                  encodeG,
                  encodeH,
                  encodeI,
                  encodeJ,
                  encodeK,
                  encodeL,
                  encodeM,
                  encodeN)
              .encode(tuple.init)
            ..addAll(encodeO.encode(tuple.last)));

  ////////////////////////////////// ProductN //////////////////////////////////

  static Encoder<A> forProduct2<A, B, C>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Tuple2<B, C> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple2(encodeB, encodeC).encode(fn(a)));

  static Encoder<A> forProduct3<A, B, C, D>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Tuple3<B, C, D> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple3(encodeB, encodeC, encodeD).encode(fn(a)));

  static Encoder<A> forProduct4<A, B, C, D, E>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Tuple4<B, C, D, E> Function(A) fn,
  ) =>
      Encoder._unkeyed(
          (a) => tuple4(encodeB, encodeC, encodeD, encodeE).encode(fn(a)));

  static Encoder<A> forProduct5<A, B, C, D, E, F>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Tuple5<B, C, D, E, F> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) =>
          tuple5(encodeB, encodeC, encodeD, encodeE, encodeF).encode(fn(a)));

  static Encoder<A> forProduct6<A, B, C, D, E, F, G>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Tuple6<B, C, D, E, F, G> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) =>
          tuple6(encodeB, encodeC, encodeD, encodeE, encodeF, encodeG)
              .encode(fn(a)));

  static Encoder<A> forProduct7<A, B, C, D, E, F, G, H>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Tuple7<B, C, D, E, F, G, H> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) =>
          tuple7(encodeB, encodeC, encodeD, encodeE, encodeF, encodeG, encodeH)
              .encode(fn(a)));

  static Encoder<A> forProduct8<A, B, C, D, E, F, G, H, I>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Tuple8<B, C, D, E, F, G, H, I> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple8(encodeB, encodeC, encodeD, encodeE,
              encodeF, encodeG, encodeH, encodeI)
          .encode(fn(a)));

  static Encoder<A> forProduct9<A, B, C, D, E, F, G, H, I, J>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Tuple9<B, C, D, E, F, G, H, I, J> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple9(encodeB, encodeC, encodeD, encodeE,
              encodeF, encodeG, encodeH, encodeI, encodeJ)
          .encode(fn(a)));

  static Encoder<A> forProduct10<A, B, C, D, E, F, G, H, I, J, K>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Tuple10<B, C, D, E, F, G, H, I, J, K> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple10(encodeB, encodeC, encodeD, encodeE,
              encodeF, encodeG, encodeH, encodeI, encodeJ, encodeK)
          .encode(fn(a)));

  static Encoder<A> forProduct11<A, B, C, D, E, F, G, H, I, J, K, L>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Tuple11<B, C, D, E, F, G, H, I, J, K, L> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple11(encodeB, encodeC, encodeD, encodeE,
              encodeF, encodeG, encodeH, encodeI, encodeJ, encodeK, encodeL)
          .encode(fn(a)));

  static Encoder<A> forProduct12<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Tuple12<B, C, D, E, F, G, H, I, J, K, L, M> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple12(
              encodeB,
              encodeC,
              encodeD,
              encodeE,
              encodeF,
              encodeG,
              encodeH,
              encodeI,
              encodeJ,
              encodeK,
              encodeL,
              encodeM)
          .encode(fn(a)));

  static Encoder<A> forProduct13<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Encoder<N> encodeN,
    Tuple13<B, C, D, E, F, G, H, I, J, K, L, M, N> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple13(
              encodeB,
              encodeC,
              encodeD,
              encodeE,
              encodeF,
              encodeG,
              encodeH,
              encodeI,
              encodeJ,
              encodeK,
              encodeL,
              encodeM,
              encodeN)
          .encode(fn(a)));

  static Encoder<A> forProduct14<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Encoder<N> encodeN,
    Encoder<O> encodeO,
    Tuple14<B, C, D, E, F, G, H, I, J, K, L, M, N, O> Function(A) fn,
  ) =>
      Encoder._unkeyed((a) => tuple14(
              encodeB,
              encodeC,
              encodeD,
              encodeE,
              encodeF,
              encodeG,
              encodeH,
              encodeI,
              encodeJ,
              encodeK,
              encodeL,
              encodeM,
              encodeN,
              encodeO)
          .encode(fn(a)));

  static Encoder<A>
      forProduct15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
    Encoder<B> encodeB,
    Encoder<C> encodeC,
    Encoder<D> encodeD,
    Encoder<E> encodeE,
    Encoder<F> encodeF,
    Encoder<G> encodeG,
    Encoder<H> encodeH,
    Encoder<I> encodeI,
    Encoder<J> encodeJ,
    Encoder<K> encodeK,
    Encoder<L> encodeL,
    Encoder<M> encodeM,
    Encoder<N> encodeN,
    Encoder<O> encodeO,
    Encoder<P> encodeP,
    Tuple15<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> Function(A) fn,
  ) =>
          Encoder._unkeyed((a) => tuple15(
                  encodeB,
                  encodeC,
                  encodeD,
                  encodeE,
                  encodeF,
                  encodeG,
                  encodeH,
                  encodeI,
                  encodeJ,
                  encodeK,
                  encodeL,
                  encodeM,
                  encodeN,
                  encodeO,
                  encodeP)
              .encode(fn(a)));
}
