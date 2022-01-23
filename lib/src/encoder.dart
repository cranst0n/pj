import 'package:dartz/dartz.dart';

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

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// Primitives /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Encoder<BigInt> bigint = string.contramap((bi) => bi.toString());

  static Encoder<bool> boolean = _primitive<bool>();

  static Encoder<DateTime> dateTime =
      string.contramap((dt) => dt.toIso8601String());

  static Encoder<double> dubble = _primitive<double>();

  static Encoder<Duration> duration =
      integer.contramap((d) => d.inMicroseconds);

  static Encoder<IList<A>> ilistOf<A>(Encoder<A> elementEncoder) =>
      listOf(elementEncoder).contramap((il) => il.toList());

  static Encoder<int> integer = _primitive<int>();

  static Encoder<List<A>> listOf<A>(Encoder<A> elementEncoder) =>
      Encoder._unkeyed((list) => list.map(elementEncoder.encode).toList());

  static Encoder<num> number = _primitive<num>();

  static Encoder<Map<String, dynamic>> object =
      _primitive<Map<String, dynamic>>();

  static Encoder<String> string = _primitive<String>();

  static Encoder<T> _primitive<T>() => Encoder._unkeyed(id);

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// Combinators /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Encoder<B> contramap<B>(A Function(B) f) =>
      Encoder._unkeyed((B b) => encode(f(b)));

  Encoder<Either<A, B>> either<B>(Encoder<B> encodeB) => Encoder._unkeyed(
      (either) => either.fold((a) => encode(a), (b) => encodeB.encode(b)));

  Encoder<A> keyed(String key) => Encoder._keyed(
      some(key), (a) => Encoder._keyed(this.key, _encodeF).encode(a));

  Encoder<A?> get nullable => Encoder._keyed(key, id);

  Encoder<Option<A>> get optional =>
      Encoder._keyed(key, (opt) => opt.fold(() => null, _encodeF));

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////// TupleN ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // TODO: https://github.com/cranst0n/pj/issues/1
  // ignore_for_file: avoid_dynamic_calls

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

  static Encoder<Tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>>
      tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
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
    Encoder<P> encodeP,
  ) =>
          Encoder._unkeyed((tuple) => tuple15(
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
                  encodeN,
                  encodeO)
              .encode(tuple.init)
            ..addAll(encodeP.encode(tuple.last)));

  static Encoder<Tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>>
      tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
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
    Encoder<P> encodeP,
    Encoder<Q> encodeQ,
  ) =>
          Encoder._unkeyed((tuple) => tuple16(
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
                  encodeN,
                  encodeO,
                  encodeP)
              .encode(tuple.init)
            ..addAll(encodeQ.encode(tuple.last)));

  static Encoder<Tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>>
      tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
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
    Encoder<P> encodeP,
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
  ) =>
          Encoder._unkeyed((tuple) => tuple17(
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
                  encodeN,
                  encodeO,
                  encodeP,
                  encodeQ)
              .encode(tuple.init)
            ..addAll(encodeR.encode(tuple.last)));

  static Encoder<
          Tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>>
      tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
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
    Encoder<P> encodeP,
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Encoder<S> encodeS,
  ) =>
          Encoder._unkeyed((tuple) => tuple18(
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
                  encodeN,
                  encodeO,
                  encodeP,
                  encodeQ,
                  encodeR)
              .encode(tuple.init)
            ..addAll(encodeS.encode(tuple.last)));

  static Encoder<
          Tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>>
      tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
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
    Encoder<P> encodeP,
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Encoder<S> encodeS,
    Encoder<T> encodeT,
  ) =>
          Encoder._unkeyed((tuple) => tuple19(
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
                  encodeN,
                  encodeO,
                  encodeP,
                  encodeQ,
                  encodeR,
                  encodeS)
              .encode(tuple.init)
            ..addAll(encodeT.encode(tuple.last)));

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// ProductN //////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

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

  static Encoder<A>
      forProduct16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
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
    Encoder<Q> encodeQ,
    Tuple16<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q> Function(A) fn,
  ) =>
          Encoder._unkeyed((a) => tuple16(
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
                  encodeP,
                  encodeQ)
              .encode(fn(a)));

  static Encoder<A>
      forProduct17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
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
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Tuple17<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R> Function(A) fn,
  ) =>
          Encoder._unkeyed((a) => tuple17(
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
                  encodeP,
                  encodeQ,
                  encodeR)
              .encode(fn(a)));

  static Encoder<A>
      forProduct18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
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
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Encoder<S> encodeS,
    Tuple18<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S> Function(A)
        fn,
  ) =>
          Encoder._unkeyed((a) => tuple18(
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
                  encodeP,
                  encodeQ,
                  encodeR,
                  encodeS)
              .encode(fn(a)));

  static Encoder<A>
      forProduct19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
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
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Encoder<S> encodeS,
    Encoder<T> encodeT,
    Tuple19<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T> Function(A)
        fn,
  ) =>
          Encoder._unkeyed((a) => tuple19(
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
                  encodeP,
                  encodeQ,
                  encodeR,
                  encodeS,
                  encodeT)
              .encode(fn(a)));

  static Encoder<A> forProduct20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P,
          Q, R, S, T, U>(
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
    Encoder<Q> encodeQ,
    Encoder<R> encodeR,
    Encoder<S> encodeS,
    Encoder<T> encodeT,
    Encoder<U> encodeU,
    Tuple20<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>
            Function(A)
        fn,
  ) =>
      Encoder._unkeyed((a) => tuple20(
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
              encodeP,
              encodeQ,
              encodeR,
              encodeS,
              encodeT,
              encodeU)
          .encode(fn(a)));
}
