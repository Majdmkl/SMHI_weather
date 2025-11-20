// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmhiRoot _$SmhiRootFromJson(Map<String, dynamic> json) => SmhiRoot(
  timeSeries: (json['timeSeries'] as List<dynamic>)
      .map((e) => SmhiTimeStep.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SmhiRootToJson(SmhiRoot instance) => <String, dynamic>{
  'timeSeries': instance.timeSeries,
};

SmhiTimeStep _$SmhiTimeStepFromJson(Map<String, dynamic> json) => SmhiTimeStep(
  validTime: json['validTime'] as String,
  parameters: (json['parameters'] as List<dynamic>)
      .map((e) => SmhiParameter.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SmhiTimeStepToJson(SmhiTimeStep instance) =>
    <String, dynamic>{
      'validTime': instance.validTime,
      'parameters': instance.parameters,
    };

SmhiParameter _$SmhiParameterFromJson(Map<String, dynamic> json) =>
    SmhiParameter(
      name: json['name'] as String,
      values: json['values'] as List<dynamic>?,
    );

Map<String, dynamic> _$SmhiParameterToJson(SmhiParameter instance) =>
    <String, dynamic>{'name': instance.name, 'values': instance.values};
