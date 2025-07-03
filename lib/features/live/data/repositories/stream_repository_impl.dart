import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/live/data/datasources/stream_data_source.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/domain/entities/repositories/stream_repository.dart';

class StreamRepositoryImpl implements StreamRepository {
  const StreamRepositoryImpl({required this.dataSource});
  final StreamDataSource dataSource;

  @override
  Future<Either<Failure, StreamCreateResponse>> createStream(
    StreamCreateRequest request,
  ) async {
    try {
      final response = await dataSource.createStream(request: request);
      return Right(response);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> stopStream(String streamId) async {
    try {
      await dataSource.stopStream(streamId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
