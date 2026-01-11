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
      name: '论语·学而',
      originalText: '子曰学而时习之不亦说乎有朋自远方来不亦乐乎人不知而不愠不亦君子乎',
      punctuatedText: '子曰：“学而时习之，不亦说乎？有朋自远方来，不亦乐乎？人不知而不愠，不亦君子乎？”',
    ),
    PunctuationExample(
      name: '道德经',
      originalText: '道可道非常道名可名非常名无名天地之始有名万物之母',
      punctuatedText: '道可道，非常道；名可名，非常名。无名，天地之始；有名，万物之母。',
    ),
  ];
}
