import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hadith feature
import '../features/hadith/data/data_source/local/hadith_local_data_source.dart';
import '../features/hadith/data/data_source/local/hadith_local_data_source_impl.dart';
import '../features/hadith/domain/repository/hadith_repository.dart';
import '../features/hadith/data/repository/hadith_repository_impl.dart';
import '../features/hadith/domain/usecase/get_ahadith_usecase.dart';
import '../features/hadith/domain/usecase/get_ahadith_usecase_impl.dart';
import '../features/hadith/presentation/screens/hadith_screen/bloc/hadith_bloc.dart';

// Radio feature
import '../features/radio/data/data_source/remote/radio_remote_data_source.dart';
import '../features/radio/data/data_source/remote/radio_remote_data_source_impl.dart';
import '../features/radio/domain/repository/radio_repository.dart';
import '../features/radio/data/repository/radio_repository_impl.dart';
import '../features/radio/domain/usecase/get_radio_stations_usecase.dart';
import '../features/radio/domain/usecase/get_radio_stations_usecase_impl.dart';
import '../features/radio/presentation/screens/radio_screen/bloc/radio_bloc.dart';

// Quran feature
import '../features/quran/data/data_source/local/quran_local_data_source.dart';
import '../features/quran/data/data_source/local/quran_local_data_source_impl.dart';
import '../features/quran/domain/repository/quran_repository.dart';
import '../features/quran/data/repository/quran_repository_impl.dart';
import '../features/quran/domain/usecase/get_all_surahs_usecase.dart';
import '../features/quran/domain/usecase/get_surah_verses_usecase.dart';
import '../features/quran/presentation/screens/quran_tab/bloc/quran_bloc.dart';
import '../features/quran/presentation/screens/sura_details_screen/bloc/sura_details_bloc.dart';

// Azkar feature
import '../features/azkar/data/data_source/local/azkar_local_data_source.dart';
import '../features/azkar/data/data_source/local/azkar_local_data_source_impl.dart';
import '../features/azkar/domain/repository/azkar_repository.dart';
import '../features/azkar/data/repository/azkar_repository_impl.dart';
import '../features/azkar/domain/usecase/get_azkar_usecase.dart';
import '../features/azkar/presentation/screens/azkar_screen/bloc/azkar_bloc.dart';

// Times feature
import '../features/times/data/data_source/remote/times_remote_data_source.dart';
import '../features/times/data/data_source/remote/times_remote_data_source_impl.dart';
import '../features/times/data/data_source/local/times_local_data_source.dart';
import '../features/times/data/data_source/local/times_local_data_source_impl.dart';
import '../features/times/domain/repository/times_repository.dart';
import '../features/times/data/repository/times_repository_impl.dart';
import '../features/times/domain/usecase/get_prayer_times_usecase.dart';
import '../features/times/domain/usecase/save_location_usecase.dart';
import '../features/times/domain/usecase/get_saved_location_usecase.dart';
import '../features/times/domain/usecase/get_cached_prayer_times_usecase.dart';
import '../features/times/presentation/screens/times_screen/bloc/times_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Data Sources
  getIt.registerLazySingleton<HadithLocalDataSource>(
    () => HadithLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<RadioRemoteDataSource>(
    () => RadioRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<TimesRemoteDataSource>(
    () => TimesRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<TimesLocalDataSource>(
    () => TimesLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerLazySingleton<HadithRepository>(
    () => HadithRepositoryImpl(getIt<HadithLocalDataSource>()),
  );
  getIt.registerLazySingleton<RadioRepository>(
    () => RadioRepositoryImpl(getIt<RadioRemoteDataSource>()),
  );
  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(getIt<QuranLocalDataSource>()),
  );
  getIt.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(getIt<AzkarLocalDataSource>()),
  );
  getIt.registerLazySingleton<TimesRepository>(
    () => TimesRepositoryImpl(getIt<TimesRemoteDataSource>(), getIt<TimesLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetAhadithUseCase>(
    () => GetAhadithUseCaseImpl(getIt<HadithRepository>()),
  );
  getIt.registerLazySingleton<GetRadioStationsUseCase>(
    () => GetRadioStationsUseCaseImpl(getIt<RadioRepository>()),
  );
  getIt.registerLazySingleton<GetAllSurahsUseCase>(
    () => GetAllSurahsUseCaseImpl(getIt<QuranRepository>()),
  );
  getIt.registerLazySingleton<GetSurahVersesUseCase>(
    () => GetSurahVersesUseCaseImpl(getIt<QuranRepository>()),
  );
  getIt.registerLazySingleton<GetAzkarUseCase>(
    () => GetAzkarUseCaseImpl(getIt<AzkarRepository>()),
  );
  getIt.registerLazySingleton<GetPrayerTimesUseCase>(
    () => GetPrayerTimesUseCaseImpl(getIt<TimesRepository>()),
  );
  getIt.registerLazySingleton<SaveLocationUseCase>(
    () => SaveLocationUseCaseImpl(getIt<TimesRepository>()),
  );
  getIt.registerLazySingleton<GetSavedLocationUseCase>(
    () => GetSavedLocationUseCaseImpl(getIt<TimesRepository>()),
  );
  getIt.registerLazySingleton<GetCachedPrayerTimesUseCase>(
    () => GetCachedPrayerTimesUseCaseImpl(getIt<TimesRepository>()),
  );

  // BLoCs
  getIt.registerFactory<HadithBloc>(
    () => HadithBloc(getIt<GetAhadithUseCase>()),
  );
  getIt.registerFactory<RadioBloc>(
    () => RadioBloc(getIt<GetRadioStationsUseCase>()),
  );
  getIt.registerFactory<QuranBloc>(
    () => QuranBloc(getIt<GetAllSurahsUseCase>(), getIt<SharedPreferences>()),
  );
  getIt.registerFactory<SuraDetailsBloc>(
    () => SuraDetailsBloc(getIt<GetSurahVersesUseCase>()),
  );
  getIt.registerFactory<AzkarBloc>(
    () => AzkarBloc(getIt<GetAzkarUseCase>()),
  );
  getIt.registerFactory<TimesBloc>(
    () => TimesBloc(
      getIt<GetPrayerTimesUseCase>(),
      getIt<SaveLocationUseCase>(),
      getIt<GetSavedLocationUseCase>(),
      getIt<GetCachedPrayerTimesUseCase>(),
    ),
  );
}
