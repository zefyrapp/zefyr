import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

abstract class HomeStreamRepository {
  Future<Either<Failure, StreamCreateResponse>> getStreams({
    required int page,
    required int pageSize,
  });
  Future<Either<Failure, StreamCreateResponse>> getStreamToken({
    required String streamId,
    String? deviceId,
  });
}
