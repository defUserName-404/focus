import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/utils/greeting.dart';

void main() {
  group('greetingFor', () {
    test('morning bucket has no name', () {
      expect(greetingFor(now: DateTime(2026, 8, 2, 8)), 'Good morning');
    });

    test('morning bucket with name', () {
      expect(greetingFor(name: 'Alex', now: DateTime(2026, 8, 2, 8)), 'Good morning, Alex');
    });

    test('afternoon bucket with name', () {
      expect(greetingFor(name: 'Sam', now: DateTime(2026, 8, 2, 14)), 'Good afternoon, Sam');
    });

    test('evening bucket with name', () {
      expect(greetingFor(name: 'Jordan', now: DateTime(2026, 8, 2, 19)), 'Good evening, Jordan');
    });

    test('late-night bucket with name', () {
      expect(greetingFor(name: 'Riley', now: DateTime(2026, 8, 2, 23)), 'Working late, Riley');
    });

    test('late-night bucket without name', () {
      expect(greetingFor(now: DateTime(2026, 8, 2, 2)), 'Working late');
    });

    test('boundary: 12:00 is afternoon', () {
      expect(greetingFor(now: DateTime(2026, 8, 2, 12)), 'Good afternoon');
    });

    test('boundary: 17:00 is evening', () {
      expect(greetingFor(now: DateTime(2026, 8, 2, 17)), 'Good evening');
    });

    test('boundary: 21:00 is working late', () {
      expect(greetingFor(now: DateTime(2026, 8, 2, 21)), 'Working late');
    });

    test('whitespace-only name is omitted', () {
      expect(greetingFor(name: '   ', now: DateTime(2026, 8, 2, 8)), 'Good morning');
    });

    test('empty string name is omitted', () {
      expect(greetingFor(name: '', now: DateTime(2026, 8, 2, 8)), 'Good morning');
    });

    test('name is trimmed', () {
      expect(greetingFor(name: '  Pat  ', now: DateTime(2026, 8, 2, 8)), 'Good morning, Pat');
    });
  });
}
