import 'package:dartz/dartz.dart';
import 'package:zefyr/common/exceptions/repository_helper.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/live/data/datasources/stream_data_source.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/domain/repositories/stream_repository.dart';

class StreamRepositoryImpl implements StreamRepository {
  const StreamRepositoryImpl({required this.dataSource});
  final StreamDataSource dataSource;

  @override
  Future<Either<Failure, StreamCreateResponse>> createStream(
    StreamCreateRequest request,
  ) async => RepositoryHelper.safeCall(
    () async => dataSource.createStream(request: request),
  );

  @override
  Future<Either<Failure, void>> stopStream(String streamId) async =>
      RepositoryHelper.safeCall(() async => dataSource.stopStream(streamId));
}
