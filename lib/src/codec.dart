import 'package:dartz/dartz.dart';
import 'package:pj/src/decoder.dart';
import 'package:pj/src/encoder.dart';

Codec<A> codecAt<A>(String label, Codec<A> codec) => codec.at(label);

Codec<BigInt> codecBigInt(String label) => codecAt(label, Codec.bigint);

Codec<bool> codecBool(String label) => codecAt(label, Codec.boolean);

Codec<DateTime> codecDateTime(String label) => codecAt(label, Codec.dateTime);

Codec<double> codecDouble(String label) => codecAt(label, Codec.dubble);

Codec<Duration> codecDuration(String label) => codecAt(label, Codec.duration);

Codec<int> codecInt(String label) => codecAt(label, Codec.integer);

Codec<IList<A>> codecIList<A>(String label, Codec<A> elementCodec) =>
    codecAt(label, Codec.ilist(elementCodec));

Codec<List<A>> codecList<A>(String label, Codec<A> elementCodec) =>
    codecAt(label, Codec.list(elementCodec));

Codec<String> codecString(String label) => codecAt(label, Codec.string);

class Codec<A> {
  final Decoder<A> decoder;
  final Encoder<A> encoder;

  // construction

  Codec._(this.decoder, this.encoder);

  DecodeResult<A> decode(dynamic json) => decoder.decode(json);
  dynamic encode(A a) => encoder.encode(a);

  // primitives

  static Codec<bool> get boolean => Codec._(Decoder.boolean, Encoder.boolean);
  static Codec<double> get dubble => Codec._(Decoder.dubble, Encoder.dubble);
  static Codec<int> get integer => Codec._(Decoder.integer, Encoder.integer);
  static Codec<String> get string => Codec._(Decoder.string, Encoder.string);
  static Codec<BigInt> get bigint => Codec._(Decoder.bigint, Encoder.bigint);

  static Codec<List<A>> list<A>(Codec<A> elementCodec) => Codec._(
      Decoder.list(elementCodec.decoder), Encoder.list(elementCodec.encoder));

  static Codec<IList<A>> ilist<A>(Codec<A> elementCodec) => Codec._(
      Decoder.ilist(elementCodec.decoder), Encoder.ilist(elementCodec.encoder));

  static Codec<DateTime> get dateTime =>
      Codec._(Decoder.dateTime, Encoder.dateTime);

  static Codec<Duration> get duration =>
      Codec._(Decoder.duration, Encoder.duration);

  // Common combinators

  Codec<A> at(String label) =>
      Codec._(decoder.at(label), encoder.labeled(label));

  Codec<B> xmap<B>(B Function(A) f, A Function(B) g) =>
      Codec._(decoder.map(f), encoder.contramap(g));

  Codec<A?> get nullable => Codec._(decoder.nullable, encoder.nullable);
  Codec<Option<A>> get optional => Codec._(decoder.optional, encoder.optional);

  // Decoder combinators

  Codec<A> recover(A a) => Codec._(decoder.recover(a), encoder);

  Codec<A> recoverWith(Codec<A> other) =>
      Codec._(decoder.recoverWith(other.decoder), encoder);

  Codec<A> withDefault(A a) => Codec._(decoder.withDefault(a), encoder);

  Codec<A> ensure(bool Function(A) predicate, String message) =>
      Codec._(decoder.ensure(predicate, message), encoder);

  Codec<A> withErrorMessage(String message) =>
      Codec._(decoder.withErrorMessage(message), encoder);

  // product

  static Codec<A> forProduct2<A, B, C>(
    Codec<B> codecB,
    Codec<C> codecC,
    A Function(B, C) fromTuple,
    Tuple2<B, C> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct2(codecB.decoder, codecC.decoder, fromTuple),
        Encoder.forProduct2(codecB.encoder, codecC.encoder, tupled),
      );

  static Codec<A> forProduct3<A, B, C, D>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    A Function(B, C, D) fromTuple,
    Tuple3<B, C, D> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct3(
            codecB.decoder, codecC.decoder, codecD.decoder, fromTuple),
        Encoder.forProduct3(
            codecB.encoder, codecC.encoder, codecD.encoder, tupled),
      );

  static Codec<A> forProduct4<A, B, C, D, E>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    A Function(B, C, D, E) fromTuple,
    Tuple4<B, C, D, E> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct4(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, fromTuple),
        Encoder.forProduct4(codecB.encoder, codecC.encoder, codecD.encoder,
            codecE.encoder, tupled),
      );

  static Codec<A> forProduct5<A, B, C, D, E, F>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    A Function(B, C, D, E, F) fromTuple,
    Tuple5<B, C, D, E, F> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct5(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, codecF.decoder, fromTuple),
        Encoder.forProduct5(codecB.encoder, codecC.encoder, codecD.encoder,
            codecE.encoder, codecF.encoder, tupled),
      );

  static Codec<A> forProduct6<A, B, C, D, E, F, G>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    A Function(B, C, D, E, F, G) fromTuple,
    Tuple6<B, C, D, E, F, G> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct6(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, codecF.decoder, codecG.decoder, fromTuple),
        Encoder.forProduct6(codecB.encoder, codecC.encoder, codecD.encoder,
            codecE.encoder, codecF.encoder, codecG.encoder, tupled),
      );

  static Codec<A> forProduct7<A, B, C, D, E, F, G, H>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    A Function(B, C, D, E, F, G, H) fromTuple,
    Tuple7<B, C, D, E, F, G, H> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct7(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            fromTuple),
        Encoder.forProduct7(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            tupled),
      );

  static Codec<A> forProduct8<A, B, C, D, E, F, G, H, I>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    A Function(B, C, D, E, F, G, H, I) fromTuple,
    Tuple8<B, C, D, E, F, G, H, I> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct8(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            fromTuple),
        Encoder.forProduct8(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            tupled),
      );

  static Codec<A> forProduct9<A, B, C, D, E, F, G, H, I, J>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    A Function(B, C, D, E, F, G, H, I, J) fromTuple,
    Tuple9<B, C, D, E, F, G, H, I, J> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct9(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            fromTuple),
        Encoder.forProduct9(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            tupled),
      );

  static Codec<A> forProduct10<A, B, C, D, E, F, G, H, I, J, K>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    A Function(B, C, D, E, F, G, H, I, J, K) fromTuple,
    Tuple10<B, C, D, E, F, G, H, I, J, K> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct10(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            fromTuple),
        Encoder.forProduct10(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            tupled),
      );

  static Codec<A> forProduct11<A, B, C, D, E, F, G, H, I, J, K, L>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    Codec<L> codecL,
    A Function(B, C, D, E, F, G, H, I, J, K, L) fromTuple,
    Tuple11<B, C, D, E, F, G, H, I, J, K, L> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct11(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            codecL.decoder,
            fromTuple),
        Encoder.forProduct11(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            codecL.encoder,
            tupled),
      );

  static Codec<A> forProduct12<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    Codec<L> codecL,
    Codec<M> codecM,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M) fromTuple,
    Tuple12<B, C, D, E, F, G, H, I, J, K, L, M> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct12(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            codecL.decoder,
            codecM.decoder,
            fromTuple),
        Encoder.forProduct12(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            codecL.encoder,
            codecM.encoder,
            tupled),
      );

  static Codec<A> forProduct13<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    Codec<L> codecL,
    Codec<M> codecM,
    Codec<N> codecN,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N) fromTuple,
    Tuple13<B, C, D, E, F, G, H, I, J, K, L, M, N> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct13(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            codecL.decoder,
            codecM.decoder,
            codecN.decoder,
            fromTuple),
        Encoder.forProduct13(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            codecL.encoder,
            codecM.encoder,
            codecN.encoder,
            tupled),
      );

  static Codec<A> forProduct14<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    Codec<L> codecL,
    Codec<M> codecM,
    Codec<N> codecN,
    Codec<O> codecO,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O) fromTuple,
    Tuple14<B, C, D, E, F, G, H, I, J, K, L, M, N, O> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct14(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            codecL.decoder,
            codecM.decoder,
            codecN.decoder,
            codecO.decoder,
            fromTuple),
        Encoder.forProduct14(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            codecL.encoder,
            codecM.encoder,
            codecN.encoder,
            codecO.encoder,
            tupled),
      );

  static Codec<A> forProduct15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
    Codec<K> codecK,
    Codec<L> codecL,
    Codec<M> codecM,
    Codec<N> codecN,
    Codec<O> codecO,
    Codec<P> codecP,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) fromTuple,
    Tuple15<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct15(
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder,
            codecI.decoder,
            codecJ.decoder,
            codecK.decoder,
            codecL.decoder,
            codecM.decoder,
            codecN.decoder,
            codecO.decoder,
            codecP.decoder,
            fromTuple),
        Encoder.forProduct15(
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder,
            codecI.encoder,
            codecJ.encoder,
            codecK.encoder,
            codecL.encoder,
            codecM.encoder,
            codecN.encoder,
            codecO.encoder,
            codecP.encoder,
            tupled),
      );
}
