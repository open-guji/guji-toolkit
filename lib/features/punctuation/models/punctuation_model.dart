import 'package:equatable/equatable.dart';

class PunctuationModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String huggingfaceUrl;
  final String modelscopeUrl;
  final String type;

  const PunctuationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.huggingfaceUrl,
    required this.modelscopeUrl,
    required this.type,
  });

  factory PunctuationModel.fromJson(Map<String, dynamic> json) {
    return PunctuationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      huggingfaceUrl: json['huggingface_url'] as String? ?? '',
      modelscopeUrl: json['modelscope_url'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'huggingface_url': huggingfaceUrl,
      'modelscope_url': modelscopeUrl,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    huggingfaceUrl,
    modelscopeUrl,
    type,
  ];
}
