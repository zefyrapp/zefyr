import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/home/domain/repositories/home_stream_repository.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

class GetStreamToken extends UseCase<StreamCreateResponse, GetStreamTokenParam>
    with UseCaseLogging<StreamCreateResponse, GetStreamTokenParam> {
  GetStreamToken(this.repository);
  final HomeStreamRepository repository;

  @override
  Future<Either<Failure, StreamCreateResponse>> executeUseCase(
    GetStreamTokenParam params,
  ) => repository.getStreamToken(
    streamId: params.streamId,
    deviceId: params.deviceId,
  );
}

class GetStreamTokenParam {
  GetStreamTokenParam({required this.streamId, this.deviceId});

  final String streamId;
  final String? deviceId;
}
