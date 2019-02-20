import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

typedef Future<Null> AsyncVoidCallBack();

void main() {
  group('ReplaySubject', () {
    test('replays the previously emitted items to every subscriber', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test(
        'replays the previously emitted items to every subscriber that directly subscribes to the Subject',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('synchronously get the previous items', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject.values, const <int>[1, 2, 3]);
    });

    test('replays the most recently emitted items up to a max size', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>(maxSize: 2);

      subject.add(1); // Should be dropped
      subject.add(2);
      subject.add(3);

      await expectLater(subject.stream, emitsInOrder(const <int>[2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[2, 3]));
    });

    test('emits done event to listeners when the subject is closed', () async {
      final subject = ReplaySubject<int>();

      await expectLater(subject.isClosed, isFalse);

      subject.add(1);
      scheduleMicrotask(() => subject.close());

      await expectLater(subject.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test('emits error events to subscribers', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      scheduleMicrotask(() => subject.addError(Exception()));

      await expectLater(subject.stream, emitsError(isException));
    });

    test('replays the previously emitted items from addStream', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await subject.addStream(Stream<int>.fromIterable(const [1, 2, 3]));

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('allows items to be added once addStream is complete', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await subject.addStream(Stream.fromIterable(const [1, 2]));
      subject.add(3);

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('allows items to be added once addStream is completes with an error',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await expectLater(
          subject.addStream(ErrorStream<int>(Exception()), cancelOnError: true),
          throwsException);

      subject.add(1);

      await expectLater(subject.stream, emits(1));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.add(1), throwsStateError);
    });

    test('does not allow errors to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addError(Error()), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addStream(Stream.fromIterable(const [1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final testOnListen = () {};
      // ignore: close_sinks
      final subject = ReplaySubject<int>(onListen: testOnListen);

      await expectLater(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final testOnListen = () {};
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await expectLater(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expectLater(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final onCancel = () => Future<void>.value(null);
      // ignore: close_sinks
      final subject = ReplaySubject<void>(onCancel: onCancel);

      await expectLater(subject.onCancel, onCancel);
    });

    test('sets onCancel callback', () async {
      final testOnCancel = () {};
      // ignore: close_sinks
      final subject = ReplaySubject<void>();

      await expectLater(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expectLater(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<void>();

      await expectLater(subject.hasListener, isFalse);

      subject.stream.listen(null);

      await expectLater(subject.hasListener, isTrue);
    });

    test('onPause unsupported', () {
      // ignore: close_sinks
      final subject = ReplaySubject<void>();

      expect(subject.isPaused, isFalse);
      expect(() => subject.onPause, throwsUnsupportedError);
      expect(() => subject.onPause = () {}, throwsUnsupportedError);
    });

    test('onResume unsupported', () {
      // ignore: close_sinks
      final subject = ReplaySubject<void>();

      expect(() => subject.onResume, throwsUnsupportedError);
      expect(() => subject.onResume = () {}, throwsUnsupportedError);
    });

    test('returns controller sink', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await expectLater(subject.sink, TypeMatcher<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final subject = ReplaySubject<int>();

      scheduleMicrotask(subject.close);

      await expectLater(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();
      final stream = subject.stream;

      subject.add(1);
      subject.add(2);

      await expectLater(stream, emitsInOrder(const <int>[1, 2]));
      await expectLater(stream, emitsInOrder(const <int>[1, 2]));
    });

    test('always returns the same stream', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      await expectLater(subject.stream, equals(subject.stream));
    });

    test('adding to sink has same behavior as adding to Subject itself',
        () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();

      subject.sink.add(1);
      subject.sink.add(2);
      subject.sink.add(3);

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('is always treated as a broadcast Stream', () async {
      // ignore: close_sinks
      final subject = ReplaySubject<int>();
      final stream = subject.asyncMap((event) => Future.value(event));

      expect(subject.isBroadcast, isTrue);
      expect(stream.isBroadcast, isTrue);
    });
  });
}
