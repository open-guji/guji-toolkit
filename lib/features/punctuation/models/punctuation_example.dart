import 'package:equatable/equatable.dart';

class PunctuationExample extends Equatable {
  final String name;
  final String originalText;
  final String punctuatedText;

  const PunctuationExample({
    required this.name,
    required this.originalText,
    required this.punctuatedText,
  });

  @override
  List<Object?> get props => [name, originalText, punctuatedText];
}

class PunctuationExamples {
  static const List<PunctuationExample> examples = [
    PunctuationExample(
      name: '論語·學而',
      originalText: '子曰學而時習之不亦說乎有朋自遠方來不亦樂乎人不知而不慍不亦君子乎',
      punctuatedText: '子曰：「學而時習之，不亦說乎？有朋自遠方來，不亦樂乎？人不知而不慍，不亦君子乎？」',
    ),
    PunctuationExample(
      name: '道德經',
      originalText:
          '道可道非常道名可名非常名無名天地之始有名萬物之母故常無欲以觀其妙常有欲以觀其徼此兩者同出而異名同謂之玄玄之又玄眾妙之門',
      punctuatedText:
          '道可道，非常道；名可名，非常名。無名，天地之始；有名，萬物之母。故常無欲，以觀其妙；常有欲，以觀其徼。此兩者，同出而異名，同謂之玄。玄之又玄，眾妙之門。',
    ),
    PunctuationExample(
      name: '史記·項羽本紀',
      originalText:
          '項籍少時學書不成去學劍又不成項梁怒之籍曰書足以記名姓而已劍一人敵不足學學萬人敵於是項梁乃教籍兵法籍大喜略知其意又不肯竟學',
      punctuatedText:
          '項籍少時，學書不成，去；學劍，又不成。項梁怒之。籍曰：「書足以記名姓而已。劍一人敵，不足學，學萬人敵。」於是項梁乃教籍兵法，籍大喜，略知其意，又不肯竟學。',
    ),
  ];
}
