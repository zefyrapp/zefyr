import 'dart:convert';

import 'package:zefyr/features/live/domain/entities/stream_model.dart';

class StreamCreateResponse {
  const StreamCreateResponse({
    required this.stream,
    required this.token,
    required this.url,
  });

  factory StreamCreateResponse.fromMap(Map<String, dynamic> map) =>
      StreamCreateResponse(
        stream: StreamModel.fromMap(map['stream'] as Map<String, dynamic>),
        token: map['token'] as String,
        url: map['url'] as String,
      );

  factory StreamCreateResponse.fromJson(String source) =>
      StreamCreateResponse.fromMap(json.decode(source) as Map<String, dynamic>);
  final StreamModel stream;
  final String token;
  final String url;

  StreamCreateResponse copyWith({
    StreamModel? stream,
    String? token,
    String? url,
  }) => StreamCreateResponse(
    stream: stream ?? this.stream,
    token: token ?? this.token,
    url: url ?? this.url,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'stream': stream.toMap(),
    'token': token,
    'url': url,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StreamCreateResponse(stream: $stream, token: $token, url: $url)';

  @override
  bool operator ==(covariant StreamCreateResponse other) {
    if (identical(this, other)) return true;

    return other.stream == stream && other.token == token && other.url == url;
  }

  @override
  int get hashCode => stream.hashCode ^ token.hashCode ^ url.hashCode;
}
