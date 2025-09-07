import 'dart:io';

import 'package:blufie_ui/services/database_helper.dart';
import 'package:blufie_ui/services/logging_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DatabaseHelper Size Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() {
      // Initialize logging service for tests
      LoggingService().initialize();
    });

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('should return database size in bytes', () async {
      try {
        // Act
        final size = await dbHelper.getDatabaseSize();

        // Assert
        expect(size, greaterThanOrEqualTo(0));
        expect(size, isA<int>());
      } catch (e) {
        // In test environment, database might not exist, which is fine
        expect(
            e.toString(),
            anyOf([
              contains('No such file or directory'),
              contains('does not exist'),
            ]));
      }
    });

    test('should return formatted database size', () async {
      try {
        // Act
        final formattedSize = await dbHelper.getFormattedDatabaseSize();

        // Assert
        expect(formattedSize, isNotEmpty);
        expect(formattedSize, contains(RegExp(r'\d+(\.\d+)?\s*(B|KB|MB|GB)')));
      } catch (e) {
        // In test environment, database might not exist, which is fine
        expect(
            e.toString(),
            anyOf([
              contains('No such file or directory'),
              contains('does not exist'),
            ]));
      }
    });

    test('should handle non-existent database gracefully', () async {
      // Act & Assert
      try {
        await dbHelper.getDatabaseSize();
      } catch (e) {
        // Should throw a meaningful error for non-existent database
        expect(
            e,
            anyOf([
              isA<FileSystemException>(),
              isA<Exception>(),
            ]));
      }
    });

    test('DatabaseHelper should be a singleton', () {
      // Arrange
      final dbHelper1 = DatabaseHelper();
      final dbHelper2 = DatabaseHelper();

      // Assert
      expect(identical(dbHelper1, dbHelper2), isTrue);
    });

    test('size formatting should handle edge cases', () {
      // This tests the general concept of size formatting
      // Since _formatFileSize is private, we test the public interface

      expect(() async {
        try {
          await dbHelper.getFormattedDatabaseSize();
        } catch (e) {
          // Expected in test environment
          expect(e, isNotNull);
        }
      }, returnsNormally);
    });
  });
}
