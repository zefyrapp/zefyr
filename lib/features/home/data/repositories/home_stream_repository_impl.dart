import 'package:dartz/dartz.dart';
import 'package:zefyr/common/exceptions/repository_helper.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/home/data/datasources/home_stream_datasource.dart';
import 'package:zefyr/features/home/domain/entities/stream_list_api_wrapper.dart';
import 'package:zefyr/features/home/domain/repositories/home_stream_repository.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

class HomeStreamRepositoryImpl implements HomeStreamRepository {
  const HomeStreamRepositoryImpl({required this.dataSource});
  final HomeStreamDataSource dataSource;

  @override
  Future<Either<Failure, StreamCreateResponse>> getStreamToken({
    required String streamId,
    String? deviceId,
  }) => RepositoryHelper.safeCall(
    () async =>
        dataSource.getStreamToken(streamId: streamId, deviceId: deviceId),
  );

  @override
  Future<Either<Failure, StreamListApiWrapper>> getStreams({
    required int page,
    required int pageSize,
  }) => RepositoryHelper.safeCall(
    () async => dataSource.getStreams(page: page, pageSize: pageSize),
  );
}
