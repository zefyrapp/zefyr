import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/home/domain/entities/stream_entity.dart';
import 'package:zefyr/features/home/domain/entities/stream_list_api_wrapper.dart';
import 'package:zefyr/features/home/usecases/get_stream_token.dart';
import 'package:zefyr/features/home/usecases/get_streams.dart';
import 'package:zefyr/features/live/domain/entities/stream_model.dart';

class HomeStreamViewModel extends StateNotifier<HomeStreamViewState> {
  HomeStreamViewModel({
    required GetStreams getStreams,
    required GetStreamToken getStreamToken,
  }) : _getStreamToken = getStreamToken,
       _getStreams = getStreams,
       super(const HomeStreamViewState());

  final GetStreams _getStreams;
  final GetStreamToken _getStreamToken;

  static const int _pageSize = 10;

  Future<void> loadStreams({bool isRefresh = false}) async {
    if (state.isLoading && !isRefresh) return;

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 0,
        hasReachedMax: false,
      );
    } else {
      if (state.hasReachedMax) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _getStreams(
      StreamPageParams(
        page: isRefresh ? 1 : state.currentPage,
        pageSize: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        final newStreams = _mapResponseToEntities(response);
        final hasReachedMax = newStreams.length < _pageSize;

        state = state.copyWith(
          isLoading: false,
          streams: isRefresh ? newStreams : [...state.streams, ...newStreams],
          currentPage: state.currentPage + 1,
          hasReachedMax: hasReachedMax,
        );
      },
    );
  }

  Future<void> getStreamToken(String streamId, {String? deviceId}) async {
    state = state.copyWith(isTokenLoading: true, tokenError: null);

    final result = await _getStreamToken(
      GetStreamTokenParam(streamId: streamId, deviceId: deviceId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isTokenLoading: false,
          tokenError: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isTokenLoading: false,
          streamToken: response.token,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearTokenError() {
    state = state.copyWith(tokenError: null);
  }

  List<StreamModel> _mapResponseToEntities(StreamListApiWrapper response) {
    // Assuming the response has a streams field with stream data
    // You'll need to adjust this based on your actual response structure
    return response.results;
    // return response.stream
    //         ?.map(
    //           (streamData) => StreamEntity(
    //             id: streamData['id'] ?? '',
    //             username: streamData['username'] ?? '',
    //             activity: streamData['activity'] ?? '',
    //             viewCount: streamData['viewCount'] ?? 0,
    //             avatarUrl: streamData['avatarUrl'] ?? '',
    //             backgroundImageUrl: streamData['backgroundImageUrl'] ?? '',
    //             isLive: streamData['isLive'] ?? false,
    //             categoryId: streamData['categoryId'],
    //             category: streamData['category'],
    //           ),
    //         )
    //         .toList() ??
    //     [];
  }
}

class HomeStreamViewState {
  const HomeStreamViewState({
    this.streams = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isTokenLoading = false,
    this.tokenError,
    this.streamToken,
  });

  final List<StreamModel> streams;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasReachedMax;
  final bool isTokenLoading;
  final String? tokenError;
  final String? streamToken;

  HomeStreamViewState copyWith({
    List<StreamModel>? streams,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasReachedMax,
    bool? isTokenLoading,
    String? tokenError,
    String? streamToken,
  }) => HomeStreamViewState(
    streams: streams ?? this.streams,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    currentPage: currentPage ?? this.currentPage,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isTokenLoading: isTokenLoading ?? this.isTokenLoading,
    tokenError: tokenError,
    streamToken: streamToken ?? this.streamToken,
  );
}
