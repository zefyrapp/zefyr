import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

abstract class StreamRepository {
  Future<Either<Failure, StreamCreateResponse>> createStream(
    StreamCreateRequest request,
  );
  Future<Either<Failure, void>> stopStream(String streamId);
}
