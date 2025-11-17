import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/forecast_viewmodel.dart';
import '../widgets/day_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final lonC = TextEditingController(text: '14.333');
  final latC = TextEditingController(text: '60.383');
  final floatFilter = [FilteringTextInputFormatter.allow(RegExp(r'^-?\\d*\\.?\\d*\$'))];

  @override
  void dispose() { lonC.dispose(); latC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forecastProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMHI Weather')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: lonC,
                    inputFormatters: floatFilter,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude (float)'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    controller: latC,
                    inputFormatters: floatFilter,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude (float)'),
                  )),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final lon = double.tryParse(lonC.text);
                      final lat = double.tryParse(latC.text);
                      if (lon == null || lat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter valid float values for lon/lat'))
                        );
                        return;
                      }
                      ref.read(forecastProvider.notifier).load(lon, lat);
                    },
                    child: const Text('Fetch'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (d) => Column(
                  children: [
                    if (d.offline)
                      Container(
                        width: double.infinity,
                        color: Colors.amber,
                        padding: const EdgeInsets.all(8),
                        child: const Text('Offline: showing cached data', textAlign: TextAlign.center),
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
    );
  }
}
