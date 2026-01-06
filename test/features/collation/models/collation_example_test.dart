import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/models/collation_example.dart';

void main() {
  group('CollationExample', () {
    test('examples 列表不应为空', () {
      expect(CollationExamples.examples, isNotEmpty);
    });

    test('每个示例应该有有效的属性', () {
      for (final example in CollationExamples.examples) {
        expect(example.id, isNotEmpty);
        expect(example.name, isNotEmpty);
        expect(example.text1, isNotEmpty);
        expect(example.text2, isNotEmpty);
      }
    });

    test('每个示例的 id 应该唯一', () {
      final ids = CollationExamples.examples.map((e) => e.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length));
    });

    test('示例应该包含繁简兼容测试用例', () {
      final hasTraditionalExample = CollationExamples.examples.any(
        (e) => e.name.contains('繁简') || e.description.contains('繁简'),
      );
      expect(hasTraditionalExample, isTrue);
    });

    test('示例应该包含标点差异测试用例', () {
      final hasPunctuationExample = CollationExamples.examples.any(
        (e) => e.name.contains('标点') || e.description.contains('标点'),
      );
      expect(hasPunctuationExample, isTrue);
    });
  });
}
