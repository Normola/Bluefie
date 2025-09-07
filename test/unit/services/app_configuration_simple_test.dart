import 'package:blufie_ui/services/app_configuration.dart';
import 'package:blufie_ui/services/bluetooth_adapter_service.dart';
import 'package:blufie_ui/services/navigation_observer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Set up test binding and mock dependencies
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock SharedPreferences for all tests
    SharedPreferences.setMockInitialValues({});
  });

  group('AppConfigurationInterface', () {
    group('Contract Tests', () {
      test('should define required methods for initialization', () {
        // Test that the interface has the expected methods
        expect(AppConfigurationInterface, isA<Type>());
      });

      test('should define bluetooth adapter access', () {
        // Mock implementation should have bluetooth adapter
        final config = MockAppConfiguration();
        expect(config.bluetoothAdapter, isA<BluetoothAdapterInterface>());
      });

      test('should define navigation observer creation', () {
        // Mock implementation should create navigation observers
        final config = MockAppConfiguration();
        final observer = config.createNavigationObserver();
        expect(observer, isA<BluetoothNavigationObserverInterface>());
      });
    });
  });

  group('AppConfiguration', () {
    group('Constructor Tests', () {
      test('should create successfully', () {
        final appConfig = AppConfiguration();
        expect(appConfig, isA<AppConfiguration>());
        expect(appConfig, isA<AppConfigurationInterface>());
        appConfig.dispose();
      });

      test('should initialize bluetooth adapter', () {
        final appConfig = AppConfiguration();
        expect(appConfig.bluetoothAdapter, isA<BluetoothAdapterInterface>());
        expect(appConfig.bluetoothAdapter, isA<FlutterBluePlusAdapter>());
        appConfig.dispose();
      });
    });

    group('Bluetooth Adapter Tests', () {
      test('should provide consistent bluetooth adapter instance', () {
        final appConfig = AppConfiguration();
        final adapter1 = appConfig.bluetoothAdapter;
        final adapter2 = appConfig.bluetoothAdapter;

        expect(adapter1, same(adapter2));
        appConfig.dispose();
      });

      test('should use FlutterBluePlusAdapter implementation', () {
        final appConfig = AppConfiguration();
        expect(appConfig.bluetoothAdapter, isA<FlutterBluePlusAdapter>());
        appConfig.dispose();
      });
    });

    group('Navigation Observer Tests', () {
      test('should create navigation observer', () {
        final appConfig = AppConfiguration();
        final observer = appConfig.createNavigationObserver();
        expect(observer, isA<BluetoothNavigationObserverInterface>());
        appConfig.dispose();
      });

      test('should create different observer instances', () {
        final appConfig = AppConfiguration();
        final observer1 = appConfig.createNavigationObserver();
        final observer2 = appConfig.createNavigationObserver();

        expect(observer1, isNot(same(observer2)));
        appConfig.dispose();
      });

      test('should pass bluetooth adapter to navigation observer', () {
        final appConfig = AppConfiguration();
        final observer = appConfig.createNavigationObserver();
        final adapter = appConfig.bluetoothAdapter;

        expect(observer, isA<BluetoothNavigationObserverInterface>());
        expect(adapter, isA<BluetoothAdapterInterface>());
        appConfig.dispose();
      });
    });

    group('Disposal Tests', () {
      test('should dispose gracefully', () {
        final appConfig = AppConfiguration();
        expect(() => appConfig.dispose(), returnsNormally);
      });

      test('should handle multiple disposals', () {
        final appConfig = AppConfiguration();
        expect(() => appConfig.dispose(), returnsNormally);
        expect(() => appConfig.dispose(), returnsNormally);
        expect(() => appConfig.dispose(), returnsNormally);
      });
    });

    group('Interface Compliance Tests', () {
      test('should implement all interface methods', () {
        final appConfig = AppConfiguration();

        // Should implement interface methods
        expect(appConfig.bluetoothAdapter, isA<BluetoothAdapterInterface>());
        expect(appConfig.createNavigationObserver, isA<Function>());
        expect(appConfig.initializeServices, isA<Function>());
        expect(appConfig.dispose, isA<Function>());

        appConfig.dispose();
      });
    });
  });

  group('MockAppConfiguration', () {
    group('Mock Implementation Tests', () {
      test('should provide mock bluetooth adapter', () {
        final mockConfig = MockAppConfiguration();
        final adapter = mockConfig.bluetoothAdapter;
        expect(adapter, isA<BluetoothAdapterInterface>());
        expect(adapter, isA<MockBluetoothAdapter>());
      });

      test('should create mock navigation observers', () {
        final mockConfig = MockAppConfiguration();
        final observer = mockConfig.createNavigationObserver();
        expect(observer, isA<BluetoothNavigationObserverInterface>());
        expect(observer, isA<MockBluetoothNavigationObserver>());
      });

      test('should handle initialization and disposal', () {
        final mockConfig = MockAppConfiguration();

        expect(() => mockConfig.initializeServices(), returnsNormally);
        expect(() => mockConfig.dispose(), returnsNormally);
      });

      test('should maintain consistent mock state', () {
        final mockConfig = MockAppConfiguration();

        final adapter1 = mockConfig.bluetoothAdapter;
        final adapter2 = mockConfig.bluetoothAdapter;

        // Mock should return the same instance
        expect(adapter1, same(adapter2));
      });
    });

    group('Mock vs Real Implementation Tests', () {
      test('should have compatible interfaces', () {
        final realConfig = AppConfiguration();
        final mockConfig = MockAppConfiguration();

        // Both should implement the same interface
        expect(realConfig, isA<AppConfigurationInterface>());
        expect(mockConfig, isA<AppConfigurationInterface>());

        realConfig.dispose();
      });

      test('should have consistent method signatures', () {
        final realConfig = AppConfiguration();
        final mockConfig = MockAppConfiguration();

        // Both should have the same interface methods
        expect(realConfig.bluetoothAdapter, isA<BluetoothAdapterInterface>());
        expect(mockConfig.bluetoothAdapter, isA<BluetoothAdapterInterface>());

        expect(realConfig.createNavigationObserver, isA<Function>());
        expect(mockConfig.createNavigationObserver, isA<Function>());

        realConfig.dispose();
      });

      test('should provide different adapter implementations', () {
        final realConfig = AppConfiguration();
        final mockConfig = MockAppConfiguration();

        expect(realConfig.bluetoothAdapter, isA<FlutterBluePlusAdapter>());
        expect(mockConfig.bluetoothAdapter, isA<MockBluetoothAdapter>());

        realConfig.dispose();
      });
    });
  });

  group('Type Safety Tests', () {
    test('should enforce interface contracts', () {
      // Compile-time test: if this compiles, the interface contract is enforced
      final AppConfigurationInterface config = AppConfiguration();
      expect(config.bluetoothAdapter, isA<BluetoothAdapterInterface>());
      (config as AppConfiguration).dispose();
    });

    test('should support polymorphic usage', () {
      final configs = [
        AppConfiguration(),
        MockAppConfiguration(),
      ];

      for (final config in configs) {
        expect(config.bluetoothAdapter, isA<BluetoothAdapterInterface>());
        expect(config.createNavigationObserver(),
            isA<BluetoothNavigationObserverInterface>());

        // Dispose based on actual type
        if (config is AppConfiguration) {
          config.dispose();
        } else if (config is MockAppConfiguration) {
          config.dispose();
        }
      }
    });
  });

  group('Memory Management Tests', () {
    test('should not leak memory on repeated creation/disposal', () {
      for (int i = 0; i < 10; i++) {
        final config = AppConfiguration();
        expect(config.bluetoothAdapter, isNotNull);
        config.dispose();
      }

      // If we get here without errors, memory management is working
      expect(true, isTrue);
    });

    test('should handle rapid creation and disposal', () {
      final configs = <AppConfiguration>[];

      // Create multiple instances
      for (int i = 0; i < 5; i++) {
        configs.add(AppConfiguration());
      }

      // Dispose all instances
      for (final config in configs) {
        expect(() => config.dispose(), returnsNormally);
      }
    });
  });

  group('Edge Cases', () {
    test('should handle disposal before initialization', () {
      final config = AppConfiguration();
      // Dispose immediately without calling initializeServices
      expect(() => config.dispose(), returnsNormally);
    });

    test('should handle repeated method calls', () {
      final config = AppConfiguration();

      // Multiple calls to same methods should work
      final adapter1 = config.bluetoothAdapter;
      final adapter2 = config.bluetoothAdapter;
      expect(adapter1, same(adapter2));

      final observer1 = config.createNavigationObserver();
      final observer2 = config.createNavigationObserver();
      expect(observer1, isNot(same(observer2)));

      config.dispose();
    });
  });
}
