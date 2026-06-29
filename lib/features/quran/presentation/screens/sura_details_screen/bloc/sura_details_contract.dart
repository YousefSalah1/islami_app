class SuraDetailsState {
  final bool isLoading;
  final List<String> verses;
  final String? errorMessage;

  SuraDetailsState({
    this.isLoading = false,
    this.verses = const [],
    this.errorMessage,
  });

  SuraDetailsState copyWith({
    bool? isLoading,
    List<String>? verses,
    String? errorMessage,
  }) {
    return SuraDetailsState(
      isLoading: isLoading ?? this.isLoading,
      verses: verses ?? this.verses,
      errorMessage: errorMessage, // replace or null
    );
  }
}

abstract class SuraDetailsEvent {}

class LoadVersesEvent extends SuraDetailsEvent {
  final int surahIndex;
  LoadVersesEvent(this.surahIndex);
}
