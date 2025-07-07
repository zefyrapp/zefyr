import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/features/home/presentation/view/streaming/stream_short_card.dart';
import 'package:zefyr/features/home/providers/home_stream_providers.dart';

class StreamingListView extends ConsumerStatefulWidget {
  const StreamingListView({super.key});

  @override
  ConsumerState<StreamingListView> createState() => _StreamingListViewState();
}

class _StreamingListViewState extends ConsumerState<StreamingListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(homeStreamViewModelProvider.notifier)
          .loadStreams(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(homeStreamViewModelProvider.notifier).loadStreams();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeStreamViewModelProvider);
    final notifier = ref.read(homeStreamViewModelProvider.notifier);

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      sliver: state.streams.isEmpty && state.isLoading
          ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            )
          : state.streams.isEmpty && state.error != null
          ? SliverToBoxAdapter(
              child: _ErrorWidget(
                error: state.error!,
                onRetry: () => notifier.loadStreams(isRefresh: true),
              ),
            )
          : state.streams.isEmpty
          ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No streams available',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 177 / 314.66,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= state.streams.length) {
                    return const _LoadingCard();
                  }

                  final stream = state.streams[index];
                  return StreamShortCard(
                    username: stream.ownerNickname,
                    activity: stream.status,
                    viewCount: stream.formattedViewCount,
                    avatarUrl: stream.previewUrl,
                    backgroundImageUrl: '',
                    onTap: () => _onStreamTap(stream.id, stream.ownerNickname),
                  );
                },
                childCount:
                    state.streams.length +
                    (state.isLoading && state.streams.isNotEmpty ? 2 : 0),
              ),
            ),
    );
  }

  Future<void> _onStreamTap(String streamId, String username) async {
    log('$username stream tapped');
    // Get stream token and navigate to stream view
    await ref
        .read(homeStreamViewModelProvider.notifier)
        .getStreamToken(streamId)
        .whenComplete(() => context.push('/remoteParticipant',));
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Error loading streams',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}
