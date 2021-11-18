import 'package:dartz/dartz.dart';

extension Tuple2Ops<A, B> on Tuple2<A, B> {
  Tuple3<A, B, C> append<C>(C c) => Tuple3(value1, value2, c);
}

extension Tuple3Ops<A, B, C> on Tuple3<A, B, C> {
  A get head => value1;
  Tuple2<B, C> get tail => Tuple2(value2, value3);

  Tuple2<A, B> get init => Tuple2(value1, value2);
  C get last => value3;

  Tuple4<A, B, C, D> append<D>(D d) => Tuple4(value1, value2, value3, d);
}

extension Tuple4Ops<A, B, C, D> on Tuple4<A, B, C, D> {
  A get head => value1;
  Tuple3<B, C, D> get tail => Tuple3(value2, value3, value4);

  Tuple3<A, B, C> get init => Tuple3(value1, value2, value3);
  D get last => value4;

  Tuple5<A, B, C, D, E> append<E>(E e) =>
      Tuple5(value1, value2, value3, value4, e);
}

extension Tuple5Ops<A, B, C, D, E> on Tuple5<A, B, C, D, E> {
  A get head => value1;
  Tuple4<B, C, D, E> get tail => Tuple4(value2, value3, value4, value5);

  Tuple4<A, B, C, D> get init => Tuple4(value1, value2, value3, value4);
  E get last => value5;

  Tuple6<A, B, C, D, E, F> append<F>(F f) =>
      Tuple6(value1, value2, value3, value4, value5, f);
}

extension Tuple6Ops<A, B, C, D, E, F> on Tuple6<A, B, C, D, E, F> {
  A get head => value1;
  Tuple5<B, C, D, E, F> get tail =>
      Tuple5(value2, value3, value4, value5, value6);

  Tuple5<A, B, C, D, E> get init =>
      Tuple5(value1, value2, value3, value4, value5);
  F get last => value6;

  Tuple7<A, B, C, D, E, F, G> append<G>(G g) =>
      Tuple7(value1, value2, value3, value4, value5, value6, g);
}

extension Tuple7Ops<A, B, C, D, E, F, G> on Tuple7<A, B, C, D, E, F, G> {
  A get head => value1;
  Tuple6<B, C, D, E, F, G> get tail =>
      Tuple6(value2, value3, value4, value5, value6, value7);

  Tuple6<A, B, C, D, E, F> get init =>
      Tuple6(value1, value2, value3, value4, value5, value6);
  G get last => value7;

  Tuple8<A, B, C, D, E, F, G, H> append<H>(H h) =>
      Tuple8(value1, value2, value3, value4, value5, value6, value7, h);
}

extension Tuple8Ops<A, B, C, D, E, F, G, H> on Tuple8<A, B, C, D, E, F, G, H> {
  A get head => value1;
  Tuple7<B, C, D, E, F, G, H> get tail =>
      Tuple7(value2, value3, value4, value5, value6, value7, value8);

  Tuple7<A, B, C, D, E, F, G> get init =>
      Tuple7(value1, value2, value3, value4, value5, value6, value7);
  H get last => value8;

  Tuple9<A, B, C, D, E, F, G, H, I> append<I>(I i) =>
      Tuple9(value1, value2, value3, value4, value5, value6, value7, value8, i);
}

extension Tuple9Ops<A, B, C, D, E, F, G, H, I>
    on Tuple9<A, B, C, D, E, F, G, H, I> {
  A get head => value1;
  Tuple8<B, C, D, E, F, G, H, I> get tail =>
      Tuple8(value2, value3, value4, value5, value6, value7, value8, value9);

  Tuple8<A, B, C, D, E, F, G, H> get init =>
      Tuple8(value1, value2, value3, value4, value5, value6, value7, value8);
  I get last => value9;

  Tuple10<A, B, C, D, E, F, G, H, I, J> append<J>(J j) => Tuple10(value1,
      value2, value3, value4, value5, value6, value7, value8, value9, j);
}

extension Tuple10Ops<A, B, C, D, E, F, G, H, I, J>
    on Tuple10<A, B, C, D, E, F, G, H, I, J> {
  A get head => value1;
  Tuple9<B, C, D, E, F, G, H, I, J> get tail => Tuple9(
      value2, value3, value4, value5, value6, value7, value8, value9, value10);

  Tuple9<A, B, C, D, E, F, G, H, I> get init => Tuple9(
      value1, value2, value3, value4, value5, value6, value7, value8, value9);
  J get last => value10;

  Tuple11<A, B, C, D, E, F, G, H, I, J, K> append<K>(K k) => Tuple11(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      k);
}

extension Tuple11Ops<A, B, C, D, E, F, G, H, I, J, K>
    on Tuple11<A, B, C, D, E, F, G, H, I, J, K> {
  A get head => value1;
  Tuple10<B, C, D, E, F, G, H, I, J, K> get tail => Tuple10(value2, value3,
      value4, value5, value6, value7, value8, value9, value10, value11);

  Tuple10<A, B, C, D, E, F, G, H, I, J> get init => Tuple10(value1, value2,
      value3, value4, value5, value6, value7, value8, value9, value10);
  K get last => value11;

  Tuple12<A, B, C, D, E, F, G, H, I, J, K, L> append<L>(L l) => Tuple12(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      l);
}

extension Tuple12Ops<A, B, C, D, E, F, G, H, I, J, K, L>
    on Tuple12<A, B, C, D, E, F, G, H, I, J, K, L> {
  A get head => value1;
  Tuple11<B, C, D, E, F, G, H, I, J, K, L> get tail => Tuple11(
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12);

  Tuple11<A, B, C, D, E, F, G, H, I, J, K> get init => Tuple11(value1, value2,
      value3, value4, value5, value6, value7, value8, value9, value10, value11);
  L get last => value12;

  Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M> append<M>(M m) => Tuple13(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      m);
}

extension Tuple13Ops<A, B, C, D, E, F, G, H, I, J, K, L, M>
    on Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M> {
  A get head => value1;
  Tuple12<B, C, D, E, F, G, H, I, J, K, L, M> get tail => Tuple12(
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13);

  Tuple12<A, B, C, D, E, F, G, H, I, J, K, L> get init => Tuple12(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12);
  M get last => value13;

  Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> append<N>(N n) => Tuple14(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13,
      n);
}

extension Tuple14Ops<A, B, C, D, E, F, G, H, I, J, K, L, M, N>
    on Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> {
  A get head => value1;
  Tuple13<B, C, D, E, F, G, H, I, J, K, L, M, N> get tail => Tuple13(
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13,
      value14);

  Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M> get init => Tuple13(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13);
  N get last => value14;

  Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O> append<O>(O o) =>
      Tuple15(value1, value2, value3, value4, value5, value6, value7, value8,
          value9, value10, value11, value12, value13, value14, o);
}

extension Tuple15Ops<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
    on Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O> {
  A get head => value1;
  Tuple14<B, C, D, E, F, G, H, I, J, K, L, M, N, O> get tail => Tuple14(
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13,
      value14,
      value15);

  Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> get init => Tuple14(
      value1,
      value2,
      value3,
      value4,
      value5,
      value6,
      value7,
      value8,
      value9,
      value10,
      value11,
      value12,
      value13,
      value14);
  O get last => value15;

  Tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> append<P>(P p) =>
      Tuple16(value1, value2, value3, value4, value5, value6, value7, value8,
          value9, value10, value11, value12, value13, value14, value15, p);
}
