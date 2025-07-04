import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/live/data/datasources/stream_data_source.dart';
import 'package:zefyr/features/live/data/repositories/stream_repository_impl.dart';
import 'package:zefyr/features/live/domain/repositories/stream_repository.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_form_model.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_form_state.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_model.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
import 'package:zefyr/features/live/usecases/create_stream.dart';
import 'package:zefyr/features/live/usecases/end_stream.dart';

part 'stream_providers.g.dart';

// DataSources
@riverpod
StreamDataSource streamDataSource(Ref ref) =>
    StreamDataSourceImpl(ref.watch(dioClientProvider), ref);

// Repository
@riverpod
StreamRepository streamRepository(Ref ref) =>
    StreamRepositoryImpl(dataSource: ref.watch(streamDataSourceProvider));

// Use Cases
@riverpod
CreateStream createStream(Ref ref) =>
    CreateStream(ref.watch(streamRepositoryProvider));

@riverpod
EndStream endStream(Ref ref) => EndStream(ref.watch(streamRepositoryProvider));

final streamViewModelProvider =
    StateNotifierProvider<StreamViewModel, StreamViewState>(
      (ref) => StreamViewModel(
        createStream: ref.read(createStreamProvider),
        endStream: ref.read(endStreamProvider),
      ),
    );

/// Провайдер состояния формы создания стрима
final streamFormProvider =
    StateNotifierProvider<StreamFormNotifier, StreamFormState>(
      (ref) => StreamFormNotifier(),
    );
