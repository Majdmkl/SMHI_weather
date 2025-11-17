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

  SmhiTimeStep({required this.validTime, required this.parameters});

  factory SmhiTimeStep.fromJson(Map<String, dynamic> json) =>
      _$SmhiTimeStepFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiTimeStepToJson(this);

  double? get temperature => _valueFor('t');
  double? get cloudiness => _valueFor('tcc_mean');

  double? _valueFor(String name) {
    final p = parameters.where((e) => e.name == name);
    if (p.isEmpty) return null;
    final vals = p.first.values;
    return (vals != null && vals.isNotEmpty) ? vals.first : null;
  }
}

@JsonSerializable()
class SmhiParameter {
  final String name;
  final List<double>? values;

  SmhiParameter({required this.name, this.values});

  factory SmhiParameter.fromJson(Map<String, dynamic> json) =>
      _$SmhiParameterFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiParameterToJson(this);
}
