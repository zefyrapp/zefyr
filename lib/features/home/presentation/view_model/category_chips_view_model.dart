import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryChipsViewModel extends StateNotifier<CategoryChipsViewState> {
  CategoryChipsViewModel() : super(const CategoryChipsViewState());

  static const List<String> _categories = [
    'For You',
    'Popular',
    'Gaming',
    'Music',
    'Sports',
    'News',
    'Entertainment',
  ];

  List<String> get categories => _categories;

  void selectCategory(int index) {
    if (index < 0 || index >= _categories.length) return;

    state = state.copyWith(
      selectedIndex: index,
      selectedCategory: _categories[index],
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIndex: null, selectedCategory: null);
  }

  String? get selectedCategory => state.selectedCategory;
  int? get selectedIndex => state.selectedIndex;
}

class CategoryChipsViewState {
  const CategoryChipsViewState({this.selectedIndex, this.selectedCategory});

  final int? selectedIndex;
  final String? selectedCategory;

  CategoryChipsViewState copyWith({
    int? selectedIndex,
    String? selectedCategory,
  }) => CategoryChipsViewState(
    selectedIndex: selectedIndex,
    selectedCategory: selectedCategory,
  );
}

// Provider for category chips
final categoryChipsViewModelProvider =
    StateNotifierProvider<CategoryChipsViewModel, CategoryChipsViewState>(
      (ref) => CategoryChipsViewModel(),
    );
