import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/providers/collation_provider.dart';

void main() {
  group('CollationNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态应该为默认值', () {
      final state = container.read(collationProvider);

      expect(state.text1, '');
      expect(state.text2, '');
      expect(state.ignorePunctuation, true);
      expect(state.ignoreTraditional, true);
      expect(state.isComparing, false);
      expect(state.result, null);
    });

    test('updateText1 应该更新文本1', () {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      final state = container.read(collationProvider);

      expect(state.text1, '春眠不觉晓');
      expect(state.text2, ''); // 不应改变
    });

    test('updateText2 应该更新文本2', () {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText2('处处闻啼鸟');
      final state = container.read(collationProvider);

      expect(state.text2, '处处闻啼鸟');
      expect(state.text1, ''); // 不应改变
    });

    test('toggleIgnorePunctuation 应该切换标点忽略选项', () {
      final notifier = container.read(collationProvider.notifier);

      notifier.toggleIgnorePunctuation(false);
      expect(container.read(collationProvider).ignorePunctuation, false);

      notifier.toggleIgnorePunctuation(true);
      expect(container.read(collationProvider).ignorePunctuation, true);
    });

    test('toggleIgnoreTraditional 应该切换繁简兼容选项', () {
      final notifier = container.read(collationProvider.notifier);

      notifier.toggleIgnoreTraditional(false);
      expect(container.read(collationProvider).ignoreTraditional, false);

      notifier.toggleIgnoreTraditional(true);
      expect(container.read(collationProvider).ignoreTraditional, true);
    });

    test('performCollation 文本为空时应该返回错误', () async {
      final notifier = container.read(collationProvider.notifier);

      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, '请输入两段文本');
      expect(state.isComparing, false);
    });

    test('performCollation 只有文本1时应该返回错误', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, '请输入两段文本');
    });

    test('performCollation 只有文本2时应该返回错误', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText2('处处闻啼鸟');
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, '请输入两段文本');
    });

    test('performCollation 相同文本应该返回100%相似度', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不觉晓');
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, 1.0);
      expect(state.result!.diff, '春眠不觉晓');
      expect(state.isComparing, false);
    });

    test('performCollation 不同文本应该返回差异', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      notifier.toggleIgnoreTraditional(false); // 不忽略繁简
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, lessThan(1.0));
      expect(state.result!.diff, contains('[-觉-]'));
      expect(state.result!.diff, contains('[+覺+]'));
      expect(state.isComparing, false);
    });

    test('performCollation 启用繁简兼容应该提高相似度', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');

      // 不忽略繁简
      notifier.toggleIgnoreTraditional(false);
      await notifier.performCollation();
      final result1 = container.read(collationProvider).result!;

      // 忽略繁简
      notifier.toggleIgnoreTraditional(true);
      await notifier.performCollation();
      final result2 = container.read(collationProvider).result!;

      expect(result2.similarity, greaterThan(result1.similarity));
    });

    test('performCollation 忽略标点应该影响结果', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓。');
      notifier.updateText2('春眠不觉晓');

      // 不忽略标点
      notifier.toggleIgnorePunctuation(false);
      await notifier.performCollation();
      final result1 = container.read(collationProvider).result!;

      // 忽略标点
      notifier.toggleIgnorePunctuation(true);
      await notifier.performCollation();
      final result2 = container.read(collationProvider).result!;

      // 忽略标点时相似度应该更高
      expect(result2.similarity, greaterThanOrEqualTo(result1.similarity));
    });

    test('performCollation 完全不同的文本应该返回低相似度', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('床前明月光');
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, lessThan(0.5));
    });

    test('performCollation 部分相同的文本应该返回中等相似度', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓，处处闻啼鸟');
      notifier.updateText2('春眠不觉晓，夜来风雨声');
      await notifier.performCollation();
      final state = container.read(collationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.similarity, greaterThan(0.3));
      expect(state.result!.similarity, lessThan(1.0));
    });

    test('clearResult 应该清空结果但保留其他状态', () async {
      final notifier = container.read(collationProvider.notifier);

      // 先执行对校
      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      await notifier.performCollation();

      // 清空结果
      notifier.clearResult();
      final state = container.read(collationProvider);

      expect(state.result!.diff, '');
      expect(state.result!.similarity, 0);
      expect(state.text1, '春眠不觉晓'); // 文本应该保留
      expect(state.text2, '春眠不覺曉'); // 文本应该保留
    });

    test('连续多次对校应该正常工作', () async {
      final notifier = container.read(collationProvider.notifier);

      // 第一次对校
      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      await notifier.performCollation();
      final result1 = container.read(collationProvider).result!;
      expect(result1.error, null);

      // 第二次对校
      notifier.updateText1('床前明月光');
      notifier.updateText2('床前明月光');
      await notifier.performCollation();
      final result2 = container.read(collationProvider).result!;
      expect(result2.error, null);
      expect(result2.similarity, 1.0);

      // 第三次对校
      notifier.updateText1('疑是地上霜');
      notifier.updateText2('疑似地上霜');
      await notifier.performCollation();
      final result3 = container.read(collationProvider).result!;
      expect(result3.error, null);
      expect(result3.similarity, lessThan(1.0));
    });
  });

  group('_formatChanges', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('格式化应该正确处理删除标记', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠');
      notifier.toggleIgnoreTraditional(false);
      await notifier.performCollation();

      final diff = container.read(collationProvider).result!.diff;
      expect(diff, contains('春眠'));
    });

    test('格式化应该正确处理添加标记', () async {
      final notifier = container.read(collationProvider.notifier);

      notifier.updateText1('春眠');
      notifier.updateText2('春眠不觉晓');
      notifier.toggleIgnoreTraditional(false);
      await notifier.performCollation();

      final diff = container.read(collationProvider).result!.diff;
      expect(diff, contains('春眠'));
    });
  });
}
