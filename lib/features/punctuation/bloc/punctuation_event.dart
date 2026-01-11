import 'package:equatable/equatable.dart';

abstract class PunctuationEvent extends Equatable {
  const PunctuationEvent();

  @override
  List<Object?> get props => [];
}

class PunctuationStarted extends PunctuationEvent {
  const PunctuationStarted();
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

class InstallModelEvent extends PunctuationEvent {
  final String modelName;
  const InstallModelEvent(this.modelName);

  @override
  List<Object?> get props => [modelName];
}

class LoadPunctuationExampleEvent extends PunctuationEvent {
  final String originalText;

  const LoadPunctuationExampleEvent({required this.originalText});

  @override
  List<Object?> get props => [originalText];
}

/// 更新下载源事件
class UpdateDownloadSourceEvent extends PunctuationEvent {
  final String source;
  const UpdateDownloadSourceEvent(this.source);

  @override
  List<Object?> get props => [source];
}

/// 内部处理进度更新事件
class UpdateProgressEvent extends PunctuationEvent {
  final double progress;
  const UpdateProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ClearPunctuationResultEvent extends PunctuationEvent {
  const ClearPunctuationResultEvent();
}

class ExportModelEvent extends PunctuationEvent {
  final String modelName;
  const ExportModelEvent(this.modelName);

  @override
  List<Object?> get props => [modelName];
}
