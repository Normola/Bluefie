import 'package:blufie_ui/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamControllerReemit', () {
    test('should emit initial value when provided', () async {
      const initialValue = 'initial';
      final controller =
          StreamControllerReemit<String>(initialValue: initialValue);

      // Listen to the stream
      final streamData = <String>[];
      final subscription = controller.stream.listen((value) {
        streamData.add(value);
      });

      // Allow stream to process
      await Future.delayed(const Duration(milliseconds: 10));

      // Should have the initial value
      expect(streamData, contains(initialValue));
      expect(controller.value, equals(initialValue));

      await subscription.cancel();
      await controller.close();
    });

    test('should emit new values and update latest value', () async {
      final controller = StreamControllerReemit<int>();

      final streamData = <int>[];
      final subscription = controller.stream.listen((value) {
        streamData.add(value);
      });

      // Add some values
      controller.add(1);
      controller.add(2);
      controller.add(3);

      // Allow stream to process
      await Future.delayed(const Duration(milliseconds: 10));

      // Check that all values were emitted
      expect(streamData, equals([1, 2, 3]));
      expect(controller.value, equals(3));

      await subscription.cancel();
      await controller.close();
    });

    test('should handle multiple listeners with initial value', () async {
      const initialValue = 42;
      final controller =
          StreamControllerReemit<int>(initialValue: initialValue);

      final listener1Data = <int>[];
      final listener2Data = <int>[];

      final subscription1 = controller.stream.listen((value) {
        listener1Data.add(value);
      });

      final subscription2 = controller.stream.listen((value) {
        listener2Data.add(value);
      });

      // Allow stream to process
      await Future.delayed(const Duration(milliseconds: 10));

      // Both listeners should get the initial value
      expect(listener1Data, contains(initialValue));
      expect(listener2Data, contains(initialValue));

      // Add a new value
      controller.add(100);
      await Future.delayed(const Duration(milliseconds: 10));

      // Both listeners should get the new value
      expect(listener1Data, contains(100));
      expect(listener2Data, contains(100));

      await subscription1.cancel();
      await subscription2.cancel();
      await controller.close();
    });

    test('should return null when no initial value and no values added', () {
      final controller = StreamControllerReemit<String>();

      expect(controller.value, isNull);

      controller.close();
    });

    test('should properly close and clean up', () async {
      final controller = StreamControllerReemit<bool>(initialValue: true);

      bool streamClosed = false;
      final subscription = controller.stream.listen(
        (value) {},
        onDone: () {
          streamClosed = true;
        },
      );

      await controller.close();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(streamClosed, true);
      await subscription.cancel();
    });
  });
}
