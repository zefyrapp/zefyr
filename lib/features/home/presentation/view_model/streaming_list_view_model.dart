import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/home/usecases/get_stream_token.dart';
import 'package:zefyr/features/home/usecases/get_streams.dart';

class HomeStreamViewModel extends StateNotifier<HomeStreamViewState> {
  HomeStreamViewModel({
    required GetStreams getStreams,
    required GetStreamToken getStreamToken,
  }) : _getStreamToken = getStreamToken,
       _getStreams = getStreams,
       super(null);
  final GetStreams _getStreams;
  final GetStreamToken _getStreamToken;
}

class HomeStreamViewState {}
