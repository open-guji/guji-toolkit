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
    // 示例1 - 异体字
    CollationExample(
      id: 'example_1',
      name: '异体字差异',
      description: '《论语》版本差异对比',
      text1: '子曰：「学而时习之，不亦说乎？有朋自远方来，不亦乐乎？人不知而不愠，不亦君子乎？」',
      text2: '子曰：「学而时习之，不亦说乎？有朋自远方来，不亦乐乎？人不知而不慍，不亦君子乎？」',
    ),

    // 示例2 - 标点差异
    CollationExample(
      id: 'example_2',
      name: '标点差异',
      description: '《三字经》标点符号对比',
      text1: '人之初性本善性相近习相远',
      text2: '人之初，性本善。性相近，习相远。',
    ),

    // 示例3 - 繁简混合
    CollationExample(
      id: 'example_3',
      name: '繁简混合',
      description: '《红楼梦》繁简版本对比',
      text1:
          '黛玉方进入房时，只见两个人搀着一位鬓发如银的老母迎上来，黛玉便知是他外祖母。方欲拜见时，早被他外祖母一把搂入怀中，心肝儿肉叫着大哭起来。当下地下侍立之人，无不掩面涕泣，黛玉也哭个不住。',
      text2:
          '黛玉方進入房時，只見兩個人攙著一位鬢髮如銀的老母迎上來，黛玉便知是他外祖母。方欲拜見時，早被他外祖母一把摟入懷中，心肝兒肉叫著大哭起來。當下地下侍立之人，無不掩面涕泣，黛玉也哭個不住。',
    ),

    // 示例4 - 多处差异
    CollationExample(
      id: 'example_4',
      name: '多处差异',
      description: '《大学》不同版本对比',
      text1: '''大学之道，在明明德，在亲民，在止于至善。
知止而后有定，定而后能静，静而后能安，安而后能虑，虑而后能得。
物有本末，事有终始，知所先后，则近道矣。
古之欲明明德于天下者，先治其国；欲治其国者，先齐其家；欲齐其家者，先修其身；欲修其身者，先正其心；欲正其心者，先诚其意；欲诚其意者，先致其知，致知在格物。
物格而后知至，知至而后意诚，意诚而后心正，心正而后身修，身修而后家齐，家齐而后国治，国治而后天下平。
自天子以至于庶人，壹是皆以修身为本。
其本乱而末治者否矣，其所厚者薄，而其所薄者厚，未之有也！
此谓知本，此谓知之至也。
所谓诚其意者，毋自欺也。如恶恶臭，如好好色，此之谓自谦。故君子必慎其独也！
小人闲居为不善，无所不至，见君子而后厌然，掩其不善，而著其善。
人之视己，如见其肺肝然，则何益矣。此谓诚于中，形于外，故君子必慎其独也。''',
      text2: '''大学之道，在明明德，在新民，在止于至善。
知止而后有定，定而后能静，静而后能安，安而后能虑，虑而后能得。
万物有本末，凡事有终始，知所先后，则近道矣。
古之欲明明德于天下者，先治其国；欲治其国者，先齐其家；欲齐其家者，先修其身；欲修其身者，先正其心；欲正其心者，先诚其意；欲诚其意者，先致其知，致知在格物。
格物而后知至，知至而后意诚，意诚而后心正，心正而后身修，身修而后家齐，家齐而后国治，国治而后天下平。
自天子以至于庶人，一是皆以修身为本。
其本乱而末治者否矣，其所厚者薄，而其所薄者厚，未之有也！
此谓知本，此谓知之至也。
所谓诚其意者，毋自欺也。如恶恶臭，如好好色，此之谓自慊。故君子必慎其独也！
小人闲居为不善，无所不至，见君子而后厌然，掩其不善，而著其善。
人之视己，如见其肺肝然，则何益矣。此谓诚于中，形于外，故君子必慎其独也。''',
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
