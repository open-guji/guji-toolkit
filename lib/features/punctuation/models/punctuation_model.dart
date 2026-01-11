import 'package:equatable/equatable.dart';

class PunctuationModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String originalAuthor;
  final String originalRepo;
  final String? onnxRepo;
  final String type;
  final String? size;

  const PunctuationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.originalAuthor,
    required this.originalRepo,
    this.onnxRepo,
    required this.type,
    this.size,
  });

  /// 获取原始模型的 HuggingFace URL
  String getOriginalUrl() {
    return 'https://huggingface.co/$originalAuthor/$originalRepo';
  }

  /// 根据下载源获取 ONNX 模型的 URL
  /// [source] 下载源: 'huggingface' 或 'hf-mirror'
  String getOnnxUrl(String source) {
    final repo = onnxRepo ?? id;
    final baseDomain = source == 'hf-mirror'
        ? 'https://hf-mirror.com'
        : 'https://huggingface.co';
    return '$baseDomain/$repo';
  }

  /// 检查是否有 ONNX 仓库
  bool get hasOnnxRepo => onnxRepo != null && onnxRepo!.isNotEmpty;

  factory PunctuationModel.fromJson(Map<String, dynamic> json) {
    return PunctuationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      originalAuthor: json['original_author'] as String? ?? '',
      originalRepo: json['original_repo'] as String? ?? '',
      onnxRepo: json['onnx_repo'] as String?,
      type: json['type'] as String? ?? '',
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'original_author': originalAuthor,
      'original_repo': originalRepo,
      if (onnxRepo != null) 'onnx_repo': onnxRepo,
      'type': type,
      if (size != null) 'size': size,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    originalAuthor,
    originalRepo,
    onnxRepo,
    type,
    size,
  ];
}
