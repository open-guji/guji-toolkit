import 'package:equatable/equatable.dart';

/// 对校事件基类
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

abstract class CollationEvent extends Equatable {
  const CollationEvent();

  @override
  List<Object?> get props => [];
}

/// 更新文本1事件
class UpdateText1Event extends CollationEvent {
  final String text;

  const UpdateText1Event(this.text);

  @override
  List<Object?> get props => [text];
}

/// 更新文本2事件
class UpdateText2Event extends CollationEvent {
  final String text;

  const UpdateText2Event(this.text);

  @override
  List<Object?> get props => [text];
}

/// 切换忽略标点选项事件
class ToggleIgnorePunctuationEvent extends CollationEvent {
  final bool value;

  const ToggleIgnorePunctuationEvent(this.value);

  @override
  List<Object?> get props => [value];
}

/// 切换繁简兼容选项事件
class ToggleIgnoreTraditionalEvent extends CollationEvent {
  final bool value;

  const ToggleIgnoreTraditionalEvent(this.value);

  @override
  List<Object?> get props => [value];
}

/// 切换异体字兼容选项事件
class ToggleIgnoreVariantsEvent extends CollationEvent {
  final bool value;

  const ToggleIgnoreVariantsEvent(this.value);

  @override
  List<Object?> get props => [value];
}

// 执行对校事件
class PerformCollationEvent extends CollationEvent {
  const PerformCollationEvent();
}

/// 加载示例事件
class LoadExampleEvent extends CollationEvent {
  final String text1;
  final String text2;

  const LoadExampleEvent({required this.text1, required this.text2});

  @override
  List<Object?> get props => [text1, text2];
}

/// 清空结果事件
class ClearResultEvent extends CollationEvent {
  const ClearResultEvent();
}

/// 检查 OpenCC 状态事件
class CheckOpenCCStatusEvent extends CollationEvent {
  const CheckOpenCCStatusEvent();
}

/// 解决差异事件
class ResolveDiffEvent extends CollationEvent {
  final int index;
  final DiffResolution resolution;

  const ResolveDiffEvent(this.index, this.resolution);

  @override
  List<Object?> get props => [index, resolution];
}
