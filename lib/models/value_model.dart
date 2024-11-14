/// __type : "NumericHealthValue"
/// numericValue : 273

class Value {
  Value({
    String? type,
    num? numericValue,
  }) {
    _type = type;
    _numericValue = numericValue;
  }

  Value.fromJson(dynamic json) {
    _type = json['__type'];
    _numericValue = json['numericValue'];
  }

  String? _type;
  num? _numericValue;

  Value copyWith({
    String? type,
    num? numericValue,
  }) =>
      Value(
        type: type ?? _type,
        numericValue: numericValue ?? _numericValue,
      );

  String? get type => _type;

  num? get numericValue => _numericValue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['__type'] = _type;
    map['numericValue'] = _numericValue;
    return map;
  }
}