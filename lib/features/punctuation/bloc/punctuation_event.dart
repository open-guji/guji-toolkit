import 'package:equatable/equatable.dart';

abstract class PunctuationEvent extends Equatable {
  const PunctuationEvent();

  @override
  List<Object?> get props => [];
}

class UpdateOriginalTextEvent extends PunctuationEvent {
  final String text;
  const UpdateOriginalTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class SelectModelEvent extends PunctuationEvent {
  final String modelName;
  const SelectModelEvent(this.modelName);

  @override
  List<Object?> get props => [modelName];
}

class PerformPunctuationEvent extends PunctuationEvent {
  const PerformPunctuationEvent();
}

class LoadPunctuationExampleEvent extends PunctuationEvent {
  final String originalText;

  const LoadPunctuationExampleEvent({required this.originalText});

  @override
  List<Object?> get props => [originalText];
}

class ClearPunctuationResultEvent extends PunctuationEvent {
  const ClearPunctuationResultEvent();
}
