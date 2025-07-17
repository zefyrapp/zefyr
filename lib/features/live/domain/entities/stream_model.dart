import 'dart:convert';

class StreamModel {
  const StreamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.previewUrl,
    required this.status,
    required this.viewersCount,
    required this.coinsCount,
    required this.owner,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory StreamModel.fromMap(Map<String, dynamic> map) => StreamModel(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    previewUrl: map['preview_url'] as String,
    status: map['status'] as String,
    viewersCount: map['viewers_count'] as int,
    coinsCount: map['coins_count'] as int,
    startedAt: map['started_at'] != null
        ? DateTime.parse(map['started_at'] as String)
        : null,
    endedAt: map['ended_at'] != null
        ? DateTime.parse(map['ended_at'] as String)
        : null,
    owner: map['owner'] as String,

    createdAt: DateTime.parse(map['created_at'] as String),
  );

  factory StreamModel.fromJson(String source) =>
      StreamModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final String title;
  final String description;
  final String previewUrl;
  final String status;
  final int viewersCount;
  final int coinsCount;
  final DateTime? startedAt;
  final DateTime? endedAt;

  final String owner;

  final DateTime createdAt;
  String get formattedViewCount {
    if (viewersCount >= 1000) {
      return '${(viewersCount / 1000).toStringAsFixed(1)}K';
    }
    return viewersCount.toString();
  }

  StreamModel copyWith({
    String? id,
    String? title,
    String? description,
    String? previewUrl,
    String? status,
    int? viewersCount,
    int? coinsCount,
    DateTime? startedAt,
    DateTime? endedAt,
    String? owner,

    DateTime? createdAt,
  }) => StreamModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    previewUrl: previewUrl ?? this.previewUrl,
    status: status ?? this.status,
    viewersCount: viewersCount ?? this.viewersCount,
    coinsCount: coinsCount ?? this.coinsCount,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    owner: owner ?? this.owner,

    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'preview_url': previewUrl,
    'status': status,
    'viewers_count': viewersCount,
    'coins_count': coinsCount,
    'started_at': startedAt,
    'ended_at': endedAt,
    'owner': owner,
    'created_at': createdAt,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StreamModel(id: $id, title: $title, description: $description, previewUrl: $previewUrl, status: $status, viewersCount: $viewersCount, coinsCount: $coinsCount, startedAt: $startedAt, endedAt: $endedAt, owner: $owner,  createdAt: $createdAt)';

  @override
  bool operator ==(covariant StreamModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.previewUrl == previewUrl &&
        other.status == status &&
        other.viewersCount == viewersCount &&
        other.coinsCount == coinsCount &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.owner == owner &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      previewUrl.hashCode ^
      status.hashCode ^
      viewersCount.hashCode ^
      coinsCount.hashCode ^
      startedAt.hashCode ^
      endedAt.hashCode ^
      owner.hashCode ^
      createdAt.hashCode;
}
