import 'package:dartz/dartz.dart';
import 'package:pj/src/error.dart';

typedef DecodeResult<A> = Either<DecodingError, A>;

/// A [Decoder] provides the ability to convert JSON into values.
class Decoder<A> {
  final Option<String> key;
  final DecodeResult<A> Function(dynamic) _decodeF;

  const Decoder._unkeyed(this._decodeF) : key = const None();

  const Decoder._keyed(this.key, this._decodeF);

  // Where the sausage is made
  DecodeResult<A> decode(dynamic json) {
    return key.fold(() => _decodeF(json), (key) {
      if (json is Map<String, dynamic> && !json.containsKey(key)) {
        return left(DecodingError.missingField(key));
      } else if (json is! Map<String, dynamic>) {
        return left(DecodingError("Expected value at field: '$key'"));
      } else {
        return _decodeF(json[key]);
      }
    });
  }

  static Decoder<A> error<A>(DecodingError reason) => lift(left(reason));

  static Decoder<A> fail<A>(String reason) => error(DecodingError(reason));

  static Decoder<A> lift<A>(DecodeResult<A> result) =>
      Decoder._unkeyed((_) => result);

  static Decoder<A> pure<A>(A value) => Decoder._unkeyed((_) => right(value));

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// Primitives /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Decoder<BigInt> bigint = string
      .emap((s) => optionOf(BigInt.tryParse(s))
          .toEither(() => 'Could not parse BigInt: $s'))
      .handleErrorWith(
          (err) => Decoder.error(DecodingError.parsingFailure(err.reason)));

  static Decoder<bool> boolean = _primitive<bool>();

  static Decoder<DateTime> dateTime = string.emap((str) =>
      catching(() => DateTime.parse(str)).leftMap((err) => err.toString()));

  static Decoder<double> dubble = _primitive<double>();

  static Decoder<Duration> duration =
      integer.map((micros) => Duration(microseconds: micros));

  static Decoder<IList<A>> ilistOf<A>(Decoder<A> elementDecoder) {
    elementDecoder.key.forEach(
      (key) =>
          // ignore: avoid_print
          print('warn: Passing a keyed ($key) decoder to an [i]List decoder.'),
    );

    return _primitive<List<dynamic>>().flatMap(
      (list) => Decoder._unkeyed(
        (_) => IList.sequenceEither(
          IList.from(list.map(elementDecoder.decode)),
        ),
      ),
    );
  }

  static Decoder<int> integer = _primitive<int>();

  static Decoder<List<A>> listOf<A>(Decoder<A> elementDecoder) =>
      ilistOf(elementDecoder).map((l) => l.toList());

  static Decoder<num> number = _primitive<num>();

  static Decoder<Map<String, dynamic>> object =
      _primitive<Map<String, dynamic>>();

  static Decoder<String> string = _primitive<String>();

  static Decoder<T> _primitive<T>() => Decoder._unkeyed((json) => json == null
      ? left(DecodingError.missingField(''))
      : catching(() => json as T)
          .leftMap((err) => DecodingError.parsingFailure(err.toString())));

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// Combinators /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Decoder<B> as<B>(B b) => map((_) => b);

  Decoder<Either<A, B>> either<B>(Decoder<B> decodeB) =>
      map<Either<A, B>>(left).recoverWith(decodeB.map(right));

  Decoder<B> emap<B>(Either<String, B> Function(A) f) => Decoder._unkeyed(
      (json) => decode(json).flatMap((a) => f(a).leftMap(DecodingError.apply)));

  Decoder<A> ensure(bool Function(A) predicate, String message) =>
      flatMap((a) => predicate(a) ? pure(a) : Decoder.fail(message));

  Decoder<B> flatMap<B>(Decoder<B> Function(A) decodeB) => Decoder._unkeyed(
      (json) => decode(json).flatMap((a) => decodeB(a).decode(json)));

  Decoder<B> fold<B>(
    B Function(DecodingError) onError,
    B Function(A) onSuccess,
  ) =>
      Decoder._unkeyed((json) => decode(json).fold(
            (err) => pure(onError(err)).decode(json),
            (a) => pure(onSuccess(a)).decode(json),
          ));

  Decoder<A> handleError(A Function(DecodingError) onFailure) =>
      handleErrorWith((err) => pure(onFailure(err)));

  Decoder<A> handleErrorWith(Decoder<A> Function(DecodingError) onFailure) =>
      Decoder._unkeyed((json) =>
          decode(json).fold((err) => onFailure(err).decode(json), right));

  Decoder<B> map<B>(B Function(A) f) =>
      Decoder._unkeyed((json) => decode(json).map(f));

  Decoder<A?> get nullable => optional.map((opt) => opt.fold(() => null, id));

  Decoder<B> omap<B>(Option<B> Function(A) f, String Function() onNone) =>
      emap((a) => f(a).toEither(onNone));

  // only recover from a missing field error
  Decoder<Option<A>> get optional =>
      Decoder._unkeyed((json) => decode(json).fold(
            (err) => err is MissingFieldFailure ? right(none()) : left(err),
            (a) => right(some(a)),
          ));

  // handle all decoding errors
  Decoder<A> recover(A a) => recoverWith(pure(a));

  Decoder<A> recoverWith(Decoder<A> other) => handleErrorWith((_) => other);

  Decoder<A> withDefault(A a) => optional.map((x) => x.getOrElse(() => a));

  Decoder<A> withErrorMessage(String message) =>
      handleErrorWith((err) => Decoder.error(err.withReason(message)));

  Decoder<A> keyed(String key) => Decoder._keyed(some(key), _decodeF);

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////// TupleN ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Decoder<Tuple2<A, B>> tuple2<A, B>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
  ) =>
      decodeA.flatMap((a) => decodeB.map((b) => Tuple2(a, b)));

  static Decoder<Tuple3<A, B, C>> tuple3<A, B, C>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
  ) =>
      tuple2(decodeA, decodeB).flatMap((t2) => decodeC.map(t2.append));

  static Decoder<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
  ) =>
      tuple3(decodeA, decodeB, decodeC).flatMap((t3) => decodeD.map(t3.append));

  static Decoder<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
  ) =>
      tuple4(decodeA, decodeB, decodeC, decodeD)
          .flatMap((t4) => decodeE.map(t4.append));

  static Decoder<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
  ) =>
      tuple5(decodeA, decodeB, decodeC, decodeD, decodeE)
          .flatMap((t5) => decodeF.map(t5.append));

  static Decoder<Tuple7<A, B, C, D, E, F, G>> tuple7<A, B, C, D, E, F, G>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
  ) =>
      tuple6(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF)
          .flatMap((t6) => decodeG.map((g) => t6.append(g)));

  static Decoder<Tuple8<A, B, C, D, E, F, G, H>> tuple8<A, B, C, D, E, F, G, H>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
  ) =>
      tuple7(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG)
          .flatMap((t7) => decodeH.map(t7.append));

  static Decoder<Tuple9<A, B, C, D, E, F, G, H, I>>
      tuple9<A, B, C, D, E, F, G, H, I>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
  ) =>
          tuple8(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH)
              .flatMap((t8) => decodeI.map(t8.append));

  static Decoder<Tuple10<A, B, C, D, E, F, G, H, I, J>>
      tuple10<A, B, C, D, E, F, G, H, I, J>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
  ) =>
          tuple9(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI)
              .flatMap((t9) => decodeJ.map(t9.append));

  static Decoder<Tuple11<A, B, C, D, E, F, G, H, I, J, K>>
      tuple11<A, B, C, D, E, F, G, H, I, J, K>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
  ) =>
          tuple10(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI, decodeJ)
              .flatMap((t10) => decodeK.map(t10.append));

  static Decoder<Tuple12<A, B, C, D, E, F, G, H, I, J, K, L>>
      tuple12<A, B, C, D, E, F, G, H, I, J, K, L>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
  ) =>
          tuple11(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI, decodeJ, decodeK)
              .flatMap((t11) => decodeL.map(t11.append));

  static Decoder<Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>>
      tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
  ) =>
          tuple12(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI, decodeJ, decodeK, decodeL)
              .flatMap((t12) => decodeM.map(t12.append));

  static Decoder<Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>>
      tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
  ) =>
          tuple13(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI, decodeJ, decodeK, decodeL, decodeM)
              .flatMap((t13) => decodeN.map(t13.append));

  static Decoder<Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>>
      tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
  ) =>
          tuple14(decodeA, decodeB, decodeC, decodeD, decodeE, decodeF, decodeG,
                  decodeH, decodeI, decodeJ, decodeK, decodeL, decodeM, decodeN)
              .flatMap((t14) => decodeO.map(t14.append));

  static Decoder<Tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>>
      tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
  ) =>
          tuple15(
                  decodeA,
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO)
              .flatMap((t15) => decodeP.map(t15.append));

  static Decoder<Tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>>
      tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
  ) =>
          tuple16(
                  decodeA,
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP)
              .flatMap((t16) => decodeQ.map(t16.append));

  static Decoder<Tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>>
      tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
  ) =>
          tuple17(
                  decodeA,
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ)
              .flatMap((t17) => decodeR.map(t17.append));

  static Decoder<
          Tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>>
      tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    Decoder<S> decodeS,
  ) =>
          tuple18(
                  decodeA,
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ,
                  decodeR)
              .flatMap((t18) => decodeS.map(t18.append));

  static Decoder<
          Tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>>
      tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    Decoder<S> decodeS,
    Decoder<T> decodeT,
  ) =>
          tuple19(
                  decodeA,
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ,
                  decodeR,
                  decodeS)
              .flatMap((t19) => decodeT.map(t19.append));

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// ProductN //////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Decoder<A> forProduct2<A, B, C>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    A Function(B, C) fn,
  ) =>
      tuple2(decodeB, decodeC).map((t) => t.apply(fn));

  static Decoder<A> forProduct3<A, B, C, D>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    A Function(B, C, D) fn,
  ) =>
      tuple3(decodeB, decodeC, decodeD).map((t) => t.apply(fn));

  static Decoder<A> forProduct4<A, B, C, D, E>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    A Function(B, C, D, E) fn,
  ) =>
      tuple4(decodeB, decodeC, decodeD, decodeE).map((t) => t.apply(fn));

  static Decoder<A> forProduct5<A, B, C, D, E, F>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    A Function(B, C, D, E, F) fn,
  ) =>
      tuple5(decodeB, decodeC, decodeD, decodeE, decodeF)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct6<A, B, C, D, E, F, G>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    A Function(B, C, D, E, F, G) fn,
  ) =>
      tuple6(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct7<A, B, C, D, E, F, G, H>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    A Function(B, C, D, E, F, G, H) fn,
  ) =>
      tuple7(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct8<A, B, C, D, E, F, G, H, I>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    A Function(B, C, D, E, F, G, H, I) fn,
  ) =>
      tuple8(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct9<A, B, C, D, E, F, G, H, I, J>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    A Function(B, C, D, E, F, G, H, I, J) fn,
  ) =>
      tuple9(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct10<A, B, C, D, E, F, G, H, I, J, K>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    A Function(B, C, D, E, F, G, H, I, J, K) fn,
  ) =>
      tuple10(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ, decodeK)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct11<A, B, C, D, E, F, G, H, I, J, K, L>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    A Function(B, C, D, E, F, G, H, I, J, K, L) fn,
  ) =>
      tuple11(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ, decodeK, decodeL)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct12<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M) fn,
  ) =>
      tuple12(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ, decodeK, decodeL, decodeM)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct13<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N) fn,
  ) =>
      tuple13(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ, decodeK, decodeL, decodeM, decodeN)
          .map((t) => t.apply(fn));

  static Decoder<A> forProduct14<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O) fn,
  ) =>
      tuple14(decodeB, decodeC, decodeD, decodeE, decodeF, decodeG, decodeH,
              decodeI, decodeJ, decodeK, decodeL, decodeM, decodeN, decodeO)
          .map((t) => t.apply(fn));

  static Decoder<A>
      forProduct15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) fn,
  ) =>
          tuple15(
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP)
              .map((t) => t.apply(fn));

  static Decoder<A>
      forProduct16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) fn,
  ) =>
          tuple16(
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ)
              .map((t) => t.apply(fn));

  static Decoder<A>
      forProduct17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) fn,
  ) =>
          tuple17(
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ,
                  decodeR)
              .map((t) => t.apply(fn));

  static Decoder<A>
      forProduct18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    Decoder<S> decodeS,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) fn,
  ) =>
          tuple18(
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ,
                  decodeR,
                  decodeS)
              .map((t) => t.apply(fn));

  static Decoder<A>
      forProduct19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    Decoder<S> decodeS,
    Decoder<T> decodeT,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) fn,
  ) =>
          tuple19(
                  decodeB,
                  decodeC,
                  decodeD,
                  decodeE,
                  decodeF,
                  decodeG,
                  decodeH,
                  decodeI,
                  decodeJ,
                  decodeK,
                  decodeL,
                  decodeM,
                  decodeN,
                  decodeO,
                  decodeP,
                  decodeQ,
                  decodeR,
                  decodeS,
                  decodeT)
              .map((t) => t.apply(fn));

  static Decoder<A> forProduct20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P,
          Q, R, S, T, U>(
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
    Decoder<G> decodeG,
    Decoder<H> decodeH,
    Decoder<I> decodeI,
    Decoder<J> decodeJ,
    Decoder<K> decodeK,
    Decoder<L> decodeL,
    Decoder<M> decodeM,
    Decoder<N> decodeN,
    Decoder<O> decodeO,
    Decoder<P> decodeP,
    Decoder<Q> decodeQ,
    Decoder<R> decodeR,
    Decoder<S> decodeS,
    Decoder<T> decodeT,
    Decoder<U> decodeU,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) fn,
  ) =>
      tuple20(
              decodeB,
              decodeC,
              decodeD,
              decodeE,
              decodeF,
              decodeG,
              decodeH,
              decodeI,
              decodeJ,
              decodeK,
              decodeL,
              decodeM,
              decodeN,
              decodeO,
              decodeP,
              decodeQ,
              decodeR,
              decodeS,
              decodeT,
              decodeU)
          .map((t) => t.apply(fn));
}
