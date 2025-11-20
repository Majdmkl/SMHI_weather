import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/forecast_viewmodel.dart';
import '../viewmodels/place_viewmodel.dart';
import '../widgets/day_card.dart';
import '../../domain/entities/place.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _lonC;
  late final TextEditingController _latC;
  late final TextEditingController _placeC;

  // OBS: inte const här, annars fick du felet du visade.
  final List<TextInputFormatter> _floatFilter = [
    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
  ];

  @override
  void initState() {
    super.initState();
    _lonC = TextEditingController(text: '14.333');
    _latC = TextEditingController(text: '60.383');
    _placeC = TextEditingController(text: '');
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
    ref.read(forecastProvider.notifier).load(lon, lat);
  }

  void _usePlace(Place p) {
    _lonC.text = p.lon.toStringAsFixed(3);
    _latC.text = p.lat.toStringAsFixed(3);
    _fetchWithCurrentLonLat();
  }

  @override
  Widget build(BuildContext context) {
    final forecastState = ref.watch(forecastProvider);
    final placeState = ref.watch(placeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMHI Weather')),
      body: SafeArea(
        child: Column(
          children: [
            // --- Rad 1: plats-sök ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _placeC,
                      decoration: InputDecoration(
                        labelText: 'Place name',
                        suffixIcon: placeState.searching
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
                                onPressed: () {
                                  ref
                                      .read(placeProvider.notifier)
                                      .search(_placeC.text);
                                },
                              ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) {
                        ref.read(placeProvider.notifier).search(v);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- Ev. sökresultat-lista (tryck för att använda) ---
            if (placeState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Place search error: ${placeState.error}',
                    style: const TextStyle(color: Colors.red)),
              ),
            if (placeState.searchResults.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: placeState.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final p = placeState.searchResults[i];
                    return ActionChip(
                      label: Text(
                        p.name.split(',').first,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => _usePlace(p),
                    );
                  },
                ),
              ),

            // --- Favoritplatser ---
            if (placeState.favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: placeState.favorites.map((p) {
                      return InputChip(
                        label: Text(p.name.split(',').first),
                        onPressed: () => _usePlace(p),
                        onDeleted: () {
                          ref.read(placeProvider.notifier).toggleFavorite(p);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

            // --- Rad 2: lon/lat + Fetch ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lonC,
                      inputFormatters: _floatFilter,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                          const InputDecoration(labelText: 'Longitude (float)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _latC,
                      inputFormatters: _floatFilter,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                          const InputDecoration(labelText: 'Latitude (float)'),
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

            // --- Själva prognosen ---
            Expanded(
              child: forecastState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (d) => Column(
                  children: [
                    if (d.offline)
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
                      child: OrientationBuilder(
                        builder: (ctx, o) => ListView.builder(
                          itemCount: d.days.length,
                          itemBuilder: (ctx, i) => DayCard(d.days[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: placeState.searchResults.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (placeState.searchResults.isEmpty) return;
                final first = placeState.searchResults.first;
                await ref.read(placeProvider.notifier).toggleFavorite(first);
              },
              icon: const Icon(Icons.star),
              label: const Text('Fav first result'),
            )
          : null,
    );
  }
}
