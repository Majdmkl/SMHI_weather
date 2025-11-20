import 'package:json_annotation/json_annotation.dart';
part 'forecast.g.dart';

@JsonSerializable()
class SmhiRoot {
  final List<SmhiTimeStep> timeSeries;
  SmhiRoot({required this.timeSeries});

  factory SmhiRoot.fromJson(Map<String, dynamic> json) =>
      _$SmhiRootFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiRootToJson(this);
}

@JsonSerializable()
class SmhiTimeStep {
  final String validTime;
  final List<SmhiParameter> parameters;

  SmhiTimeStep({
    required this.validTime,
    required this.parameters,
  });

  factory SmhiTimeStep.fromJson(Map<String, dynamic> json) =>
      _$SmhiTimeStepFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiTimeStepToJson(this);

  // --------- DATA GETTERS ---------

  /// Temperatur (°C)
  double? get temperature => _valueFor('t');

  /// Molnighet (0–100 %)
  double? get cloudiness => _valueFor('tcc_mean');

  /// Nederbörd (mm/h)
  double? get precipitation => _valueFor('pmean');

  /// Vindhastighet (m/s)
  double? get windSpeed => _valueFor('ws');

  // --------- HJÄLPFUNKTION ---------

  double? _valueFor(String name) {
    final match = parameters.firstWhere(
      (p) => p.name == name,
      orElse: () => SmhiParameter(name: name, values: null),
    );

    final vals = match.values;
    if (vals == null || vals.isEmpty) return null;

    final v = vals.first;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

@JsonSerializable()
class SmhiParameter {
  final String name;
  final List<dynamic>? values; // vissa SMHI-värden är int/double

  SmhiParameter({
    required this.name,
    this.values,
  });

  factory SmhiParameter.fromJson(Map<String, dynamic> json) =>
      _$SmhiParameterFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiParameterToJson(this);
}
