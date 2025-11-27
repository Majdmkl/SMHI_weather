import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/forecast_viewmodel.dart';
import '../../viewmodels/place_viewmodel.dart';
import '../../models/place_model.dart';
import '../widgets/day_card.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _lonC;
  late final TextEditingController _latC;
  late final TextEditingController _placeC;

  final List<TextInputFormatter> _floatFilter = [
    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
  ];

  @override
  void initState() {
    super.initState();
    _lonC = TextEditingController(text: '14.333');
    _latC = TextEditingController(text: '60.383');
    _placeC = TextEditingController();
  }

  @override
  void dispose() {
    _lonC.dispose();
    _latC.dispose();
    _placeC.dispose();
    super.dispose();
  }

  void _fetchWithCurrentLonLat() {
    final lon = double.tryParse(_lonC.text);
    final lat = double.tryParse(_latC.text);

    if (lon == null || lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid float values for lon/lat')),
      );
      return;
    }

    // Använd ViewModel
    context.read<ForecastViewModel>().loadForecast(lon, lat);
  }

  void _usePlace(Place p) {
    _placeC.text = p.name.split(',').first;
    _lonC.text = p.lon.toStringAsFixed(3);
    _latC.text = p.lat.toStringAsFixed(3);
    _fetchWithCurrentLonLat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMHI Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Favourites',
            onPressed: () async {
              final Place? selected = await Navigator.push<Place>(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );

              if (selected != null) {
                _usePlace(selected);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Place search field
            Padding(
              padding: const EdgeInsets.all(12),
              child: Consumer<PlaceViewModel>(
                builder: (context, placeVM, child) {
                  return TextField(
                    controller: _placeC,
                    decoration: InputDecoration(
                      labelText: 'Place name',
                      suffixIcon: placeVM.isSearching
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => placeVM.search(_placeC.text),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => placeVM.search(v),
                  );
                },
              ),
            ),

            // Search error
            Consumer<PlaceViewModel>(
              builder: (context, placeVM, child) {
                if (placeVM.error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Place search error: ${placeVM.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),

            // Search results
            Consumer<PlaceViewModel>(
              builder: (context, placeVM, child) {
                if (placeVM.searchResults.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: placeVM.searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final p = placeVM.searchResults[i];
                      return ActionChip(
                        label: Text(
                          p.name.split(',').first,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => _usePlace(p),
                      );
                    },
                  ),
                );
              },
            ),

            // Lon/Lat input
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lonC,
                      inputFormatters: _floatFilter,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude (float)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _latC,
                      inputFormatters: _floatFilter,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude (float)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _fetchWithCurrentLonLat,
                    child: const Text('Fetch'),
                  ),
                ],
              ),
            ),

            // Forecast display
            Expanded(
              child: Consumer<ForecastViewModel>(
                builder: (context, forecastVM, child) {
                  if (forecastVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (forecastVM.error != null) {
                    return Center(child: Text('Error: ${forecastVM.error}'));
                  }

                  if (!forecastVM.hasData) {
                    return const Center(
                      child: Text('No forecast data. Enter coordinates and press Fetch.'),
                    );
                  }

                  return Column(
                    children: [
                      if (forecastVM.isOffline)
                        Container(
                          width: double.infinity,
                          color: Colors.amber,
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            'Offline: showing cached data',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: forecastVM.days.length,
                          itemBuilder: (ctx, i) => DayCard(forecastVM.days[i]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<PlaceViewModel>(
        builder: (context, placeVM, child) {
          if (placeVM.searchResults.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              final first = placeVM.searchResults.first;
              placeVM.toggleFavorite(first);
            },
            icon: const Icon(Icons.star),
            label: const Text('Fav first result'),
          );
        },
      ),
    );
  }
}