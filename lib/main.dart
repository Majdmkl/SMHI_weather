// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/smhi_api_service.dart';
import 'services/place_api_service.dart';
import 'services/cache_service.dart';

// Repositories
import 'repositories/forecast_repository.dart';
import 'repositories/place_repository.dart';

// Use Cases
import 'use_cases/load_forecast_use_case.dart';
import 'use_cases/search_place_use_case.dart';
import 'use_cases/manage_favorites_use_case.dart';

// ViewModels
import 'viewmodels/forecast_viewmodel.dart';
import 'viewmodels/place_viewmodel.dart';

// Views
import 'views/pages/home_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // === LAYER 1: Services (External dependencies) ===
    final smhiApiService = SmhiApiService();
    final placeApiService = PlaceApiService();
    final cacheService = CacheService();

    // === LAYER 2: Repositories (Data access abstraction) ===
    final forecastRepository = ForecastRepository(
      apiService: smhiApiService,
      cacheService: cacheService,
    );

    final placeRepository = PlaceRepository(
      apiService: placeApiService,
    );

    // === LAYER 3: Use Cases (Business logic) ===
    final loadForecastUseCase = LoadForecastUseCase(forecastRepository);
    final searchPlaceUseCase = SearchPlaceUseCase(placeRepository);
    final manageFavoritesUseCase = ManageFavoritesUseCase(placeRepository);

    // === LAYER 4: ViewModels (Presentation logic) ===
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ForecastViewModel(
            loadForecastUseCase: loadForecastUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaceViewModel(
            searchPlaceUseCase: searchPlaceUseCase,
            manageFavoritesUseCase: manageFavoritesUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SMHI Weather',
        theme: ThemeData(useMaterial3: true),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}