import 'package:dartz/dartz.dart';

import 'error.dart';

typedef DecodeResult<A> = Either<DecodingError, A>;

Decoder<A> decodeAt<A>(String label, Decoder<A> decoder) => decoder.at(label);

Decoder<BigInt> decodeBigInt(String label) => decodeAt(label, Decoder.bigint);

Decoder<bool> decodeBool(String label) => decodeAt(label, Decoder.boolean);

Decoder<DateTime> decodeDateTime(String label) =>
    decodeAt(label, Decoder.dateTime);

Decoder<double> decodeDouble(String label) => decodeAt(label, Decoder.dubble);

Decoder<Duration> decodeDuration(String label) =>
    decodeAt(label, Decoder.duration);

Decoder<int> decodeInt(String label) => decodeAt(label, Decoder.integer);

Decoder<IList<A>> decodeIList<A>(String label, Decoder<A> elementDecoder) =>
    decodeAt(label, Decoder.ilist(elementDecoder));

Decoder<List<A>> decodeList<A>(String label, Decoder<A> elementDecoder) =>
    decodeAt(label, Decoder.list(elementDecoder));

Decoder<Map<String, dynamic>> decodeObject(String label) =>
    decodeAt(label, Decoder.object);

Decoder<String> decodeString(String label) => decodeAt(label, Decoder.string);

class Decoder<A> {
  final Option<String> label;
  final DecodeResult<A> Function(dynamic) _decodeF;

  // construction

  const Decoder._unlabeled(this._decodeF) : label = const None();

  Decoder._labeled(String label, this._decodeF) : label = some(label);

  static Decoder<A> pure<A>(A value) => Decoder._unlabeled((_) => right(value));

  static Decoder<A> lift<A>(DecodeResult<A> result) =>
      Decoder._unlabeled((_) => result);

  static Decoder<A> fail<A>(String reason) => error(DecodingError(reason));

  static Decoder<A> error<A>(DecodingError reason) =>
      Decoder._unlabeled((_) => left(reason));

  // Where the sausage is made
  DecodeResult<A> decode(dynamic json) {
    return label.fold(() => _decodeF(json), (label) {
      if (json is Map<String, dynamic> && !json.containsKey(label)) {
        return left(DecodingError.missingField(label));
      } else if (json is! Map<String, dynamic>) {
        return left(DecodingError("Expected object at field: '$label'"));
      } else {
        return _decodeF(json[label]);
      }
    });
  }

  // primitives

  static Decoder<Map<String, dynamic>> get object =>
      _primitive<Map<String, dynamic>>();

  static Decoder<bool> get boolean => _primitive<bool>();
  static Decoder<double> get dubble => _primitive<double>();
  static Decoder<int> get integer => _primitive<int>();
  static Decoder<String> get string => _primitive<String>();
  static Decoder<BigInt> get bigint => string.map(BigInt.parse);

  static Decoder<List<A>> list<A>(Decoder<A> elementDecoder) =>
      ilist(elementDecoder).map((l) => l.toList());

  static Decoder<IList<A>> ilist<A>(Decoder<A> elementDecoder) =>
      _primitive<List<dynamic>>().flatMap(
        (list) => Decoder._unlabeled(
          (_) => IList.sequenceEither(
            IList.from(list.map((el) => elementDecoder.decode(el))),
          ),
        ),
      );

  static Decoder<DateTime> get dateTime => string.emap((str) =>
      catching(() => DateTime.parse(str)).leftMap((l) => l.toString()));

  static Decoder<Duration> get duration =>
      integer.map((micros) => Duration(microseconds: micros));

  static Decoder<T> _primitive<T>() => Decoder._unlabeled((json) => json == null
      ? left(DecodingError.missingField(''))
      : catching(() => json as T)
          .leftMap((l) => DecodingError.parsingFailure(l.toString())));

  // combinators

  Decoder<B> map<B>(B Function(A) f) =>
      Decoder._unlabeled((json) => decode(json).map(f));

  Decoder<B> flatMap<B>(Decoder<B> Function(A) decodeB) => Decoder._unlabeled(
      (json) => decode(json).flatMap((a) => decodeB(a).decode(json)));

  Decoder<B> as<B>(B b) => map((_) => b);

  Decoder<B> emap<B>(Either<String, B> Function(A) f) => Decoder._unlabeled(
      (json) => decode(json).flatMap((a) => f(a).leftMap(DecodingError.apply)));

  Decoder<B> omap<B>(Option<B> Function(A) f, String onNone) =>
      emap((a) => f(a).toEither(() => onNone));

  Decoder<B> fold<B>(
    B Function(DecodingError) onError,
    B Function(A) onSuccess,
  ) =>
      Decoder._unlabeled((json) => decode(json).fold(
            (err) => pure(onError(err)).decode(json),
            (a) => pure(onSuccess(a)).decode(json),
          ));

  Decoder<A> handleError(A Function(DecodingError) onFailure) =>
      handleErrorWith((err) => pure(onFailure(err)));

  Decoder<A> handleErrorWith(Decoder<A> Function(DecodingError) onFailure) =>
      Decoder._unlabeled((json) =>
          decode(json).fold((err) => onFailure(err).decode(json), right));

  // handle all decoding errors
  Decoder<A> recover(A a) => recoverWith(pure(a));

  Decoder<A> recoverWith(Decoder<A> other) => handleErrorWith((_) => other);

  // only recover from a missing field error
  Decoder<Option<A>> get optional =>
      Decoder._unlabeled((json) => decode(json).fold(
            (err) => err is MissingFieldFailure ? right(none()) : left(err),
            (r) => right(some(r)),
          ));

  Decoder<A> withDefault(A a) => optional.map((x) => x.getOrElse(() => a));

  Decoder<A?> get nullable => optional.map((opt) => opt.fold(() => null, id));

  Decoder<Either<A, B>> either<B>(Decoder<B> decodeB) =>
      map<Either<A, B>>(left).recoverWith(decodeB.map(right));

  Decoder<A> ensure(bool Function(A) predicate, String message) =>
      flatMap((a) => predicate(a) ? pure(a) : Decoder.fail(message));

  Decoder<A> withErrorMessage(String message) =>
      handleErrorWith((err) => Decoder.error(err.withReason(message)));

  // downfield

  Decoder<A> at(String label) => Decoder._labeled(label, _decodeF);

  // tuple

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
      tuple2(decodeA, decodeB)
          .flatMap((t2) => decodeC.map((c) => t2.append(c)));

  static Decoder<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
  ) =>
      tuple3(decodeA, decodeB, decodeC)
          .flatMap((t3) => decodeD.map((d) => t3.append(d)));

  static Decoder<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
  ) =>
      tuple4(decodeA, decodeB, decodeC, decodeD)
          .flatMap((t4) => decodeE.map((e) => t4.append(e)));

  static Decoder<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Decoder<A> decodeA,
    Decoder<B> decodeB,
    Decoder<C> decodeC,
    Decoder<D> decodeD,
    Decoder<E> decodeE,
    Decoder<F> decodeF,
  ) =>
      tuple5(decodeA, decodeB, decodeC, decodeD, decodeE)
          .flatMap((t5) => decodeF.map((f) => t5.append(f)));

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
          .flatMap((t7) => decodeH.map((h) => t7.append(h)));

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
              .flatMap((t8) => decodeI.map((i) => t8.append(i)));

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
              .flatMap((t9) => decodeJ.map((j) => t9.append(j)));

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
              .flatMap((t10) => decodeK.map((j) => t10.append(j)));

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
              .flatMap((t11) => decodeL.map((l) => t11.append(l)));

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
              .flatMap((t12) => decodeM.map((m) => t12.append(m)));

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
              .flatMap((t13) => decodeN.map((n) => t13.append(n)));

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
              .flatMap((t14) => decodeO.map((o) => t14.append(o)));

  // product

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
}
