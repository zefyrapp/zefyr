import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zefyr/features/live/domain/entities/stream_model.dart';

class StreamListApiWrapper {
  const StreamListApiWrapper({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory StreamListApiWrapper.fromMap(Map<String, dynamic> map) =>
      StreamListApiWrapper(
        count: map['count'] as int,
        next: map['next'] as dynamic,
        previous: map['previous'] as dynamic,
        results: map['results'] != null
            ? List<StreamModel>.from(
                (map['results'] as List).map(
                  (e) => StreamModel.fromMap(e as Map<String, dynamic>),
                ),
              )
            : [],
      );

  factory StreamListApiWrapper.fromJson(String source) =>
      StreamListApiWrapper.fromMap(json.decode(source) as Map<String, dynamic>);

  final int count;
  final dynamic next;
  final dynamic previous;
  final List<StreamModel> results;

  StreamListApiWrapper copyWith({
    int? count,
    dynamic next,
    dynamic previous,
    List<StreamModel>? results,
  }) => StreamListApiWrapper(
    count: count ?? this.count,
    next: next ?? this.next,
    previous: previous ?? this.previous,
    results: results ?? this.results,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'count': count,
    'next': next,
    'previous': previous,
    'results': results,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StreamListApiWrapper(count: $count, next: $next, previous: $previous, results: $results)';

  @override
  bool operator ==(covariant StreamListApiWrapper other) {
    if (identical(this, other)) return true;

    return other.count == count &&
        other.next == next &&
        other.previous == previous &&
        listEquals(other.results, results);
  }

  @override
  int get hashCode =>
      count.hashCode ^ next.hashCode ^ previous.hashCode ^ results.hashCode;
}
