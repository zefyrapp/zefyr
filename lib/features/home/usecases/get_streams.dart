import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/home/domain/entities/stream_list_api_wrapper.dart';
import 'package:zefyr/features/home/domain/repositories/home_stream_repository.dart';

class GetStreams extends UseCase<StreamListApiWrapper, StreamPageParams>
    with UseCaseLogging<StreamListApiWrapper, StreamPageParams> {
  GetStreams(this.repository);
  final HomeStreamRepository repository;

  @override
  Future<Either<Failure, StreamListApiWrapper>> executeUseCase(
    StreamPageParams params,
  ) => repository.getStreams(page: params.page, pageSize: params.pageSize);
}

class StreamPageParams {
  const StreamPageParams({required this.page, required this.pageSize});

  final int page;
  final int pageSize;
}
