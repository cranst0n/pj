import 'package:dartz/dartz.dart';
import 'package:pj/src/decoder.dart';
import 'package:pj/src/encoder.dart';
import 'package:pj/src/error.dart';

/// A Codec is a product of an [Encoder] and a [Decoder]. It provides
/// the functionality of converting between values of type A and JSON.
///
/// It mainly exists to make building encoders/decoders more convenient.
class Codec<A> {
  final Decoder<A> decoder;
  final Encoder<A> encoder;

  Codec._(this.decoder, this.encoder);

  DecodeResult<A> decode(dynamic json) => decoder.decode(json);
  dynamic encode(A a) => encoder.encode(a);

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// Codec combinators /////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Codec<A> at(String key) => Codec._(decoder.at(key), encoder.at(key));

  Codec<B> exmap<B>(Either<DecodingError, B> Function(A) f, A Function(B) g) =>
      Codec._(decoder.emap(f), encoder.contramap(g));

  Codec<A?> get nullable => Codec._(decoder.nullable, encoder.nullable);

  Codec<Option<A>> get optional => Codec._(decoder.optional, encoder.optional);

  Codec<B> xmap<B>(B Function(A) f, A Function(B) g) =>
      Codec._(decoder.map(f), encoder.contramap(g));

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////// Decoder combinators /////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Codec<A> ensure(bool Function(A) predicate, String message) =>
      Codec._(decoder.ensure(predicate, message), encoder);

  Codec<A> recover(A a) => Codec._(decoder.recover(a), encoder);

  Codec<A> recoverWith(Codec<A> other) =>
      Codec._(decoder.recoverWith(other.decoder), encoder);

  Codec<A> withDefault(A a) => Codec._(decoder.withDefault(a), encoder);

  Codec<A> withErrorMessage(String message) =>
      Codec._(decoder.withErrorMessage(message), encoder);

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// Primitives /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Codec<BigInt> bigint = Codec._(Decoder.bigint, Encoder.bigint);

  static Codec<bool> boolean = Codec._(Decoder.boolean, Encoder.boolean);

  static Codec<DateTime> dateTime = Codec._(Decoder.dateTime, Encoder.dateTime);

  static Codec<double> dubble = Codec._(Decoder.dubble, Encoder.dubble);

  static Codec<Duration> duration = Codec._(Decoder.duration, Encoder.duration);

  static Codec<IList<A>> ilistOf<A>(Codec<A> elementCodec) => Codec._(
      Decoder.ilistOf(elementCodec.decoder),
      Encoder.ilistOf(elementCodec.encoder));

  static Codec<int> integer = Codec._(Decoder.integer, Encoder.integer);

  static Codec<List<A>> listOf<A>(Codec<A> elementCodec) => Codec._(
      Decoder.listOf(elementCodec.decoder),
      Encoder.listOf(elementCodec.encoder));

  static Codec<num> number = Codec._(Decoder.number, Encoder.number);

  static Codec<Map<String, dynamic>> object =
      Codec._(Decoder.object, Encoder.object);

  static Codec<String> string = Codec._(Decoder.string, Encoder.string);

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////// TupleN ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Codec<Tuple2<A, B>> tuple2<A, B>(
    Codec<A> codecA,
    Codec<B> codecB,
  ) =>
      Codec._(
        Decoder.tuple2(codecA.decoder, codecB.decoder),
        Encoder.tuple2(codecA.encoder, codecB.encoder),
      );

  static Codec<Tuple3<A, B, C>> tuple3<A, B, C>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
  ) =>
      Codec._(
        Decoder.tuple3(codecA.decoder, codecB.decoder, codecC.decoder),
        Encoder.tuple3(codecA.encoder, codecB.encoder, codecC.encoder),
      );

  static Codec<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
  ) =>
      Codec._(
        Decoder.tuple4(
            codecA.decoder, codecB.decoder, codecC.decoder, codecD.decoder),
        Encoder.tuple4(
            codecA.encoder, codecB.encoder, codecC.encoder, codecD.encoder),
      );

  static Codec<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
  ) =>
      Codec._(
        Decoder.tuple5(codecA.decoder, codecB.decoder, codecC.decoder,
            codecD.decoder, codecE.decoder),
        Encoder.tuple5(codecA.encoder, codecB.encoder, codecC.encoder,
            codecD.encoder, codecE.encoder),
      );

  static Codec<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
  ) =>
      Codec._(
        Decoder.tuple6(codecA.decoder, codecB.decoder, codecC.decoder,
            codecD.decoder, codecE.decoder, codecF.decoder),
        Encoder.tuple6(codecA.encoder, codecB.encoder, codecC.encoder,
            codecD.encoder, codecE.encoder, codecF.encoder),
      );

  static Codec<Tuple7<A, B, C, D, E, F, G>> tuple7<A, B, C, D, E, F, G>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
  ) =>
      Codec._(
        Decoder.tuple7(codecA.decoder, codecB.decoder, codecC.decoder,
            codecD.decoder, codecE.decoder, codecF.decoder, codecG.decoder),
        Encoder.tuple7(codecA.encoder, codecB.encoder, codecC.encoder,
            codecD.encoder, codecE.encoder, codecF.encoder, codecG.encoder),
      );

  static Codec<Tuple8<A, B, C, D, E, F, G, H>> tuple8<A, B, C, D, E, F, G, H>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
  ) =>
      Codec._(
        Decoder.tuple8(
            codecA.decoder,
            codecB.decoder,
            codecC.decoder,
            codecD.decoder,
            codecE.decoder,
            codecF.decoder,
            codecG.decoder,
            codecH.decoder),
        Encoder.tuple8(
            codecA.encoder,
            codecB.encoder,
            codecC.encoder,
            codecD.encoder,
            codecE.encoder,
            codecF.encoder,
            codecG.encoder,
            codecH.encoder),
      );

  static Codec<Tuple9<A, B, C, D, E, F, G, H, I>>
      tuple9<A, B, C, D, E, F, G, H, I>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
  ) =>
          Codec._(
            Decoder.tuple9(
                codecA.decoder,
                codecB.decoder,
                codecC.decoder,
                codecD.decoder,
                codecE.decoder,
                codecF.decoder,
                codecG.decoder,
                codecH.decoder,
                codecI.decoder),
            Encoder.tuple9(
                codecA.encoder,
                codecB.encoder,
                codecC.encoder,
                codecD.encoder,
                codecE.encoder,
                codecF.encoder,
                codecG.encoder,
                codecH.encoder,
                codecI.encoder),
          );

  static Codec<Tuple10<A, B, C, D, E, F, G, H, I, J>>
      tuple10<A, B, C, D, E, F, G, H, I, J>(
    Codec<A> codecA,
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    Codec<G> codecG,
    Codec<H> codecH,
    Codec<I> codecI,
    Codec<J> codecJ,
  ) =>
          Codec._(
            Decoder.tuple10(
                codecA.decoder,
                codecB.decoder,
                codecC.decoder,
                codecD.decoder,
                codecE.decoder,
                codecF.decoder,
                codecG.decoder,
                codecH.decoder,
                codecI.decoder,
                codecJ.decoder),
            Encoder.tuple10(
                codecA.encoder,
                codecB.encoder,
                codecC.encoder,
                codecD.encoder,
                codecE.encoder,
                codecF.encoder,
                codecG.encoder,
                codecH.encoder,
                codecI.encoder,
                codecJ.encoder),
          );

  static Codec<Tuple11<A, B, C, D, E, F, G, H, I, J, K>>
      tuple11<A, B, C, D, E, F, G, H, I, J, K>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple11(
                codecA.decoder,
                codecB.decoder,
                codecC.decoder,
                codecD.decoder,
                codecE.decoder,
                codecF.decoder,
                codecG.decoder,
                codecH.decoder,
                codecI.decoder,
                codecJ.decoder,
                codecK.decoder),
            Encoder.tuple11(
                codecA.encoder,
                codecB.encoder,
                codecC.encoder,
                codecD.encoder,
                codecE.encoder,
                codecF.encoder,
                codecG.encoder,
                codecH.encoder,
                codecI.encoder,
                codecJ.encoder,
                codecK.encoder),
          );

  static Codec<Tuple12<A, B, C, D, E, F, G, H, I, J, K, L>>
      tuple12<A, B, C, D, E, F, G, H, I, J, K, L>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple12(
                codecA.decoder,
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
                codecL.decoder),
            Encoder.tuple12(
                codecA.encoder,
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
                codecL.encoder),
          );

  static Codec<Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>>
      tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple13(
                codecA.decoder,
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
                codecM.decoder),
            Encoder.tuple13(
                codecA.encoder,
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
                codecM.encoder),
          );

  static Codec<Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>>
      tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple14(
                codecA.decoder,
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
                codecN.decoder),
            Encoder.tuple14(
                codecA.encoder,
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
                codecN.encoder),
          );

  static Codec<Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>>
      tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple15(
                codecA.decoder,
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
                codecO.decoder),
            Encoder.tuple15(
                codecA.encoder,
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
                codecO.encoder),
          );

  static Codec<Tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>>
      tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
    Codec<A> codecA,
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
  ) =>
          Codec._(
            Decoder.tuple16(
                codecA.decoder,
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
                codecP.decoder),
            Encoder.tuple16(
                codecA.encoder,
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
                codecP.encoder),
          );

  static Codec<Tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>>
      tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
    Codec<A> codecA,
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
    Codec<Q> codecQ,
  ) =>
          Codec._(
            Decoder.tuple17(
                codecA.decoder,
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
                codecQ.decoder),
            Encoder.tuple17(
                codecA.encoder,
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
                codecQ.encoder),
          );

  static Codec<Tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>>
      tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
    Codec<A> codecA,
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
    Codec<Q> codecQ,
    Codec<R> codecR,
  ) =>
          Codec._(
            Decoder.tuple18(
                codecA.decoder,
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
                codecQ.decoder,
                codecR.decoder),
            Encoder.tuple18(
                codecA.encoder,
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
                codecQ.encoder,
                codecR.encoder),
          );

  static Codec<Tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>>
      tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
    Codec<A> codecA,
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    Codec<S> codecS,
  ) =>
          Codec._(
            Decoder.tuple19(
                codecA.decoder,
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
                codecQ.decoder,
                codecR.decoder,
                codecS.decoder),
            Encoder.tuple19(
                codecA.encoder,
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
                codecQ.encoder,
                codecR.encoder,
                codecS.encoder),
          );

  static Codec<
          Tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>>
      tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
    Codec<A> codecA,
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    Codec<S> codecS,
    Codec<T> codecT,
  ) =>
          Codec._(
            Decoder.tuple20(
                codecA.decoder,
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
                codecQ.decoder,
                codecR.decoder,
                codecS.decoder,
                codecT.decoder),
            Encoder.tuple20(
                codecA.encoder,
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
                codecQ.encoder,
                codecR.encoder,
                codecS.encoder,
                codecT.encoder),
          );

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// ProductN //////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  static Codec<A> forProduct2<A, B, C>(
    Codec<B> codecB,
    Codec<C> codecC,
    A Function(B, C) apply,
    Tuple2<B, C> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct2(codecB.decoder, codecC.decoder, apply),
        Encoder.forProduct2(codecB.encoder, codecC.encoder, tupled),
      );

  static Codec<A> forProduct3<A, B, C, D>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    A Function(B, C, D) apply,
    Tuple3<B, C, D> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct3(
            codecB.decoder, codecC.decoder, codecD.decoder, apply),
        Encoder.forProduct3(
            codecB.encoder, codecC.encoder, codecD.encoder, tupled),
      );

  static Codec<A> forProduct4<A, B, C, D, E>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    A Function(B, C, D, E) apply,
    Tuple4<B, C, D, E> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct4(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, apply),
        Encoder.forProduct4(codecB.encoder, codecC.encoder, codecD.encoder,
            codecE.encoder, tupled),
      );

  static Codec<A> forProduct5<A, B, C, D, E, F>(
    Codec<B> codecB,
    Codec<C> codecC,
    Codec<D> codecD,
    Codec<E> codecE,
    Codec<F> codecF,
    A Function(B, C, D, E, F) apply,
    Tuple5<B, C, D, E, F> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct5(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, codecF.decoder, apply),
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
    A Function(B, C, D, E, F, G) apply,
    Tuple6<B, C, D, E, F, G> Function(A) tupled,
  ) =>
      Codec._(
        Decoder.forProduct6(codecB.decoder, codecC.decoder, codecD.decoder,
            codecE.decoder, codecF.decoder, codecG.decoder, apply),
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
    A Function(B, C, D, E, F, G, H) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K, L) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K, L, M) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O) apply,
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
            apply),
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
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) apply,
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
            apply),
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

  static Codec<A>
      forProduct16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
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
    Codec<Q> codecQ,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) apply,
    Tuple16<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q> Function(A) tupled,
  ) =>
          Codec._(
            Decoder.forProduct16(
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
                codecQ.decoder,
                apply),
            Encoder.forProduct16(
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
                codecQ.encoder,
                tupled),
          );

  static Codec<A>
      forProduct17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) apply,
    Tuple17<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R> Function(A)
        tupled,
  ) =>
          Codec._(
            Decoder.forProduct17(
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
                codecQ.decoder,
                codecR.decoder,
                apply),
            Encoder.forProduct17(
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
                codecQ.encoder,
                codecR.encoder,
                tupled),
          );

  static Codec<A>
      forProduct18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    Codec<S> codecS,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) apply,
    Tuple18<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S> Function(A)
        tupled,
  ) =>
          Codec._(
            Decoder.forProduct18(
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
                codecQ.decoder,
                codecR.decoder,
                codecS.decoder,
                apply),
            Encoder.forProduct18(
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
                codecQ.encoder,
                codecR.encoder,
                codecS.encoder,
                tupled),
          );

  static Codec<A>
      forProduct19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    Codec<S> codecS,
    Codec<T> codecT,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) apply,
    Tuple19<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T> Function(A)
        tupled,
  ) =>
          Codec._(
            Decoder.forProduct19(
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
                codecQ.decoder,
                codecR.decoder,
                codecS.decoder,
                codecT.decoder,
                apply),
            Encoder.forProduct19(
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
                codecQ.encoder,
                codecR.encoder,
                codecS.encoder,
                codecT.encoder,
                tupled),
          );

  static Codec<A> forProduct20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P,
          Q, R, S, T, U>(
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
    Codec<Q> codecQ,
    Codec<R> codecR,
    Codec<S> codecS,
    Codec<T> codecT,
    Codec<U> codecU,
    A Function(B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U)
        apply,
    Tuple20<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>
            Function(A)
        tupled,
  ) =>
      Codec._(
        Decoder.forProduct20(
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
            codecQ.decoder,
            codecR.decoder,
            codecS.decoder,
            codecT.decoder,
            codecU.decoder,
            apply),
        Encoder.forProduct20(
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
            codecQ.encoder,
            codecR.encoder,
            codecS.encoder,
            codecT.encoder,
            codecU.encoder,
            tupled),
      );
}
