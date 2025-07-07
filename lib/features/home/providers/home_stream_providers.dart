import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/home/data/datasources/home_stream_datasource.dart';
import 'package:zefyr/features/home/data/repositories/home_stream_repository_impl.dart';
import 'package:zefyr/features/home/domain/repositories/home_stream_repository.dart';
import 'package:zefyr/features/home/presentation/view_model/category_chips_view_model.dart';
import 'package:zefyr/features/home/presentation/view_model/streaming_list_view_model.dart';
import 'package:zefyr/features/home/usecases/get_stream_token.dart';
import 'package:zefyr/features/home/usecases/get_streams.dart';

part 'home_stream_providers.g.dart';

@riverpod
HomeStreamDataSource homeStreamDataSource(Ref ref) =>
    HomeStreamDataSourceImpl(ref.watch(dioClientProvider), ref);

@riverpod
HomeStreamRepository homeStreamRepository(Ref ref) => HomeStreamRepositoryImpl(
  dataSource: ref.watch(homeStreamDataSourceProvider),
);

@riverpod
GetStreams getStreams(Ref ref) =>
    GetStreams(ref.watch(homeStreamRepositoryProvider));
@riverpod
GetStreamToken getStreamToken(Ref ref) =>
    GetStreamToken(ref.watch(homeStreamRepositoryProvider));
final homeStreamViewModelProvider =
    AutoDisposeStateNotifierProvider<HomeStreamViewModel, HomeStreamViewState>(
      (ref) => HomeStreamViewModel(
        getStreams: ref.read(getStreamsProvider),
        getStreamToken: ref.read(getStreamTokenProvider),
      ),
    );
// Provider for listening to category changes and refreshing streams
final streamsWithCategoryProvider = Provider.autoDispose<void>((ref) {
  final categoryState = ref.watch(categoryChipsViewModelProvider);
  final streamNotifier = ref.read(homeStreamViewModelProvider.notifier);

  // Listen to category changes and refresh streams when category changes
  ref.listen<CategoryChipsViewState>(categoryChipsViewModelProvider, (
    previous,
    next,
  ) {
    if (previous?.selectedCategory != next.selectedCategory) {
      streamNotifier.loadStreams(isRefresh: true);
    }
  });
});
