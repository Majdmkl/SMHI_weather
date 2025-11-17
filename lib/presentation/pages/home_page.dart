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
  late final TextEditingController _lonC;
  late final TextEditingController _latC;

  // Tillåt siffror, ev. minus, och punkt ELLER komma som decimal.
  final List<TextInputFormatter> _floatFilter =  [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*([.,]\d*)?$'),),];

  @override
  void initState() {
    super.initState();
    _lonC = TextEditingController(text: '17.617');
    _latC = TextEditingController(text: '59.180');
  }

  @override
  void dispose() {
    _lonC.dispose();
    _latC.dispose();
    super.dispose();
  }

  double? _parseFloat(String s) =>
      double.tryParse(s.replaceAll(',', '.'));

  void _onFetch() {
    final lon = _parseFloat(_lonC.text.trim());
    final lat = _parseFloat(_latC.text.trim());
    if (lon == null || lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid float values for lon/lat')),
      );
      return;
    }
    ref.read(forecastProvider.notifier).load(lon, lat);
  }

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
                  Expanded(
                    child: TextFormField(
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
                    child: TextFormField(
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
                    onPressed: _onFetch,
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
                        child: const Text(
                          'Offline: showing cached data',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: OrientationBuilder(
                        builder: (ctx, orientation) => ListView.builder(
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
