import '../../../../domain/entities/hadith_entity.dart';

class HadithState {
  final bool isLoading;
  final bool isInitialLoad;
  final bool isSuccess;
  final List<HadithEntity> data;
  final String? errorMessage;

  HadithState({
    this.isLoading = false,
    this.isInitialLoad = true,
    this.isSuccess = false,
    this.data = const [],
    this.errorMessage,
  });

  HadithState copyWith({
    bool? isLoading,
    bool? isInitialLoad,
    bool? isSuccess,
    List<HadithEntity>? data,
    String? errorMessage,
  }) {
    return HadithState(
      isLoading: isLoading ?? this.isLoading,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      isSuccess: isSuccess ?? this.isSuccess,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

abstract class HadithEvent {}

class LoadHadithEvent extends HadithEvent {}
