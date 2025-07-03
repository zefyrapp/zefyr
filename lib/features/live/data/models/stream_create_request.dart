import 'dart:convert';

class StreamCreateRequest {
  const StreamCreateRequest({
    required this.title,
    required this.description,
    required this.previewUrl,
  });

  factory StreamCreateRequest.fromMap(Map<String, dynamic> map) =>
      StreamCreateRequest(
        title: map['title'] as String,
        description: map['description'] as String,
        previewUrl: map['preview_url'] as String,
      );

  factory StreamCreateRequest.fromJson(String source) =>
      StreamCreateRequest.fromMap(json.decode(source) as Map<String, dynamic>);
  final String title;
  final String description;
  final String previewUrl;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'title': title,
    'description': description,
    'preview_url': previewUrl,
  };

  StreamCreateRequest copyWith({
    String? title,
    String? description,
    String? previewUrl,
  }) => StreamCreateRequest(
    title: title ?? this.title,
    description: description ?? this.description,
    previewUrl: previewUrl ?? this.previewUrl,
  );

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StreamCreateRequest(title: $title, description: $description, previewUrl: $previewUrl)';

  @override
  bool operator ==(covariant StreamCreateRequest other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.previewUrl == previewUrl;
  }

  @override
  int get hashCode =>
      title.hashCode ^ description.hashCode ^ previewUrl.hashCode;
}
