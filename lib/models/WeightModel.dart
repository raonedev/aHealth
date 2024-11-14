import 'package:ahealth/models/value_model.dart';

/// uuid : "36706dc3-599e-4024-81b8-a4d1504a2068"
/// value : {"__type":"NumericHealthValue","numericValue":50.0}
/// type : "WEIGHT"
/// unit : "KILOGRAM"
/// dateFrom : "2024-10-27T17:19:16.187"
/// dateTo : "2024-10-27T17:19:16.187"
/// sourcePlatform : "googleHealthConnect"
/// sourceDeviceId : "UP1A.231005.007"
/// sourceId : ""
/// sourceName : "com.sec.android.app.shealth"
/// recordingMethod : "unknown"

class WeightModel {
  WeightModel({
      String? uuid, 
      Value? value, 
      String? type, 
      String? unit, 
      String? dateFrom, 
      String? dateTo, 
      String? sourcePlatform, 
      String? sourceDeviceId, 
      String? sourceId, 
      String? sourceName, 
      String? recordingMethod,}){
    _uuid = uuid;
    _value = value;
    _type = type;
    _unit = unit;
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    _sourcePlatform = sourcePlatform;
    _sourceDeviceId = sourceDeviceId;
    _sourceId = sourceId;
    _sourceName = sourceName;
    _recordingMethod = recordingMethod;
}

  WeightModel.fromJson(dynamic json) {
    _uuid = json['uuid'];
    _value = json['value'] != null ? Value.fromJson(json['value']) : null;
    _type = json['type'];
    _unit = json['unit'];
    _dateFrom = json['dateFrom'];
    _dateTo = json['dateTo'];
    _sourcePlatform = json['sourcePlatform'];
    _sourceDeviceId = json['sourceDeviceId'];
    _sourceId = json['sourceId'];
    _sourceName = json['sourceName'];
    _recordingMethod = json['recordingMethod'];
  }
  String? _uuid;
  Value? _value;
  String? _type;
  String? _unit;
  String? _dateFrom;
  String? _dateTo;
  String? _sourcePlatform;
  String? _sourceDeviceId;
  String? _sourceId;
  String? _sourceName;
  String? _recordingMethod;
WeightModel copyWith({  String? uuid,
  Value? value,
  String? type,
  String? unit,
  String? dateFrom,
  String? dateTo,
  String? sourcePlatform,
  String? sourceDeviceId,
  String? sourceId,
  String? sourceName,
  String? recordingMethod,
}) => WeightModel(  uuid: uuid ?? _uuid,
  value: value ?? _value,
  type: type ?? _type,
  unit: unit ?? _unit,
  dateFrom: dateFrom ?? _dateFrom,
  dateTo: dateTo ?? _dateTo,
  sourcePlatform: sourcePlatform ?? _sourcePlatform,
  sourceDeviceId: sourceDeviceId ?? _sourceDeviceId,
  sourceId: sourceId ?? _sourceId,
  sourceName: sourceName ?? _sourceName,
  recordingMethod: recordingMethod ?? _recordingMethod,
);
  String? get uuid => _uuid;
  Value? get value => _value;
  String? get type => _type;
  String? get unit => _unit;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  String? get sourcePlatform => _sourcePlatform;
  String? get sourceDeviceId => _sourceDeviceId;
  String? get sourceId => _sourceId;
  String? get sourceName => _sourceName;
  String? get recordingMethod => _recordingMethod;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uuid'] = _uuid;
    if (_value != null) {
      map['value'] = _value?.toJson();
    }
    map['type'] = _type;
    map['unit'] = _unit;
    map['dateFrom'] = _dateFrom;
    map['dateTo'] = _dateTo;
    map['sourcePlatform'] = _sourcePlatform;
    map['sourceDeviceId'] = _sourceDeviceId;
    map['sourceId'] = _sourceId;
    map['sourceName'] = _sourceName;
    map['recordingMethod'] = _recordingMethod;
    return map;
  }

}

