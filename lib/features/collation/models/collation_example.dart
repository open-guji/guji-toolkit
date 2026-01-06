import 'package:equatable/equatable.dart';

/// 对校示例模型
class CollationExample extends Equatable {
  final String id;
  final String name;
  final String description;
  final String text1;
  final String text2;

  const CollationExample({
    required this.id,
    required this.name,
    required this.description,
    required this.text1,
    required this.text2,
  });

  @override
  List<Object?> get props => [id, name, description, text1, text2];
}

/// 预设的对校示例
class CollationExamples {
  static const List<CollationExample> examples = [
    // 简单示例 - 单句差异
    CollationExample(
      id: 'simple_1',
      name: '简单示例：单句差异',
      description: '《论语》版本差异对比',
      text1: '子曰：「学而时习之，不亦说乎？有朋自远方来，不亦乐乎？」',
      text2: '子曰：「学而时习之，不亦悦乎？有朋自远方来，不亦乐乎？」',
    ),

    // 简单示例 - 标点差异
    CollationExample(
      id: 'simple_2',
      name: '简单示例：标点差异',
      description: '《孟子》标点符号对比',
      text1: '人之初性本善性相近习相远',
      text2: '人之初，性本善。性相近，习相远。',
    ),

    // 复杂示例 - 多处差异
    CollationExample(
      id: 'complex_1',
      name: '复杂示例：多处差异',
      description: '《道德经》不同版本对比',
      text1: '''道可道，非常道。名可名，非常名。
无名天地之始；有名万物之母。
故常无欲，以观其妙；常有欲，以观其徼。
此两者，同出而异名，同谓之玄。玄之又玄，众妙之门。''',
      text2: '''道可道也，非恒道也。名可名也，非恒名也。
无名，万物之始也；有名，万物之母也。
故恒无欲也，以观其妙；恒有欲也，以观其所徼。
两者同出，异名同谓。玄之又玄，众妙之门。''',
    ),

    // 复杂示例 - 繁简混合
    CollationExample(
      id: 'complex_2',
      name: '复杂示例：繁简混合',
      description: '《红楼梦》繁简版本对比',
      text1: '''黛玉方进入房时，只见两个人搀着一位鬓发如银的老母迎上来，
黛玉便知是他外祖母。方欲拜见时，早被他外祖母一把搂入怀中，
心肝儿肉叫着大哭起来。当下地下侍立之人，无不掩面涕泣，
黛玉也哭个不住。''',
      text2: '''黛玉方進入房時，只見兩個人攙著一位鬢髮如銀的老母迎上來，
黛玉便知是他外祖母。方欲拜見時，早被他外祖母一把摟入懷中，
心肝兒肉叫著大哭起來。當下地下侍立之人，無不掩面涕泣，
黛玉也哭個不住。''',
    ),

    // 复杂示例 - 大段文字异文
    CollationExample(
      id: 'complex_3',
      name: '复杂示例：大段异文',
      description: '《庄子》不同传本对比',
      text1: '''北冥有鱼，其名为鲲。鲲之大，不知其几千里也。
化而为鸟，其名为鹏。鹏之背，不知其几千里也；
怒而飞，其翼若垂天之云。是鸟也，海运则将徙于南冥。
南冥者，天池也。''',
      text2: '''北溟有鱼，其名曰鲲。鲲之大，不知几千里也。
化为鸟，其名曰鹏。鹏之背，不知几千里也；
奋而飞，其翼若垂天之云。是鸟也，海运则徙于南溟。
南溟者，天池也。齐谐者，志怪者也。''',
    ),
  ];

  /// 根据ID获取示例
  static CollationExample? getById(String id) {
    try {
      return examples.firstWhere((example) => example.id == id);
    } catch (e) {
      return null;
    }
  }
}
