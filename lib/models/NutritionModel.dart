/// uuid : "f1a1c6b5-1ee1-4568-aad0-afb79920c21a"
/// value : {"name":"Breakfast","calories":362.0,"protein":5.5,"fat":18.700000762939453,"carbs":43.099998474121094,"calcium":0.06370000076293945,"cholesterol":0.011,"fiber":2.299999952316284,"iron":0.0020999999046325685,"potassium":0.295,"sodium":0.8300000000000001,"sugar":10.399999618530273}
/// type : "NUTRITION"
/// unit : "NO_UNIT"
/// dateFrom : "2024-11-12T13:09:48.262"
/// dateTo : "2024-11-12T13:09:49.262"
/// sourcePlatform : "googleHealthConnect"
/// sourceDeviceId : "UP1A.231005.007"
/// sourceId : ""
/// sourceName : "com.sec.android.app.shealth"
/// recordingMethod : "unknown"

class NutritionModel {
  NutritionModel({
      String? uuid, 
      ValueFood? value, 
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

  NutritionModel.fromJson(dynamic json) {
    _uuid = json['uuid'];
    _value = json['value'] != null ? ValueFood.fromJson(json['value']) : null;
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
  ValueFood? _value;
  String? _type;
  String? _unit;
  String? _dateFrom;
  String? _dateTo;
  String? _sourcePlatform;
  String? _sourceDeviceId;
  String? _sourceId;
  String? _sourceName;
  String? _recordingMethod;
NutritionModel copyWith({  String? uuid,
  ValueFood? value,
  String? type,
  String? unit,
  String? dateFrom,
  String? dateTo,
  String? sourcePlatform,
  String? sourceDeviceId,
  String? sourceId,
  String? sourceName,
  String? recordingMethod,
}) => NutritionModel(  uuid: uuid ?? _uuid,
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
  ValueFood? get value => _value;
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

/// name : "Breakfast"
/// calories : 362.0
/// protein : 5.5
/// fat : 18.700000762939453
/// carbs : 43.099998474121094
/// calcium : 0.06370000076293945
/// cholesterol : 0.011
/// fiber : 2.299999952316284
/// iron : 0.0020999999046325685
/// potassium : 0.295
/// sodium : 0.8300000000000001
/// sugar : 10.399999618530273

class ValueFood {
  ValueFood({
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? calcium,
    double? cholesterol,
    double? fiber,
    double? iron,
    double? potassium,
    double? sodium,
    double? sugar,
    double? quantity,
    String? unit,
    String? servingDescription,
    String? metricServingAmount,
    String? metricServingUnit,
    String? numberOfUnits,
    String? measurementDescription,
    double? saturatedFat,
    double? polyunsaturatedFat,
    double? monounsaturatedFat,
    double? vitaminA,
    double? vitaminC,
  }) {
    _name = name;
    _calories = calories;
    _protein = protein;
    _fat = fat;
    _carbs = carbs;
    _calcium = calcium;
    _cholesterol = cholesterol;
    _fiber = fiber;
    _iron = iron;
    _potassium = potassium;
    _sodium = sodium;
    _sugar = sugar;
    _quantity = quantity;
    _unit = unit;
    _servingDescription = servingDescription;
    _metricServingAmount = metricServingAmount;
    _metricServingUnit = metricServingUnit;
    _numberOfUnits = numberOfUnits;
    _measurementDescription = measurementDescription;
    _saturatedFat = saturatedFat;
    _polyunsaturatedFat = polyunsaturatedFat;
    _monounsaturatedFat = monounsaturatedFat;
    _vitaminA = vitaminA;
    _vitaminC = vitaminC;
  }

  ValueFood.fromJson(dynamic json) {
    _name = json['name'];
    _calories = json['calories'];
    _protein = json['protein'];
    _fat = json['fat'];
    _carbs = json['carbs'];
    _calcium = json['calcium'];
    _cholesterol = json['cholesterol'];
    _fiber = json['fiber'];
    _iron = json['iron'];
    _potassium = json['potassium'];
    _sodium = json['sodium'];
    _sugar = json['sugar'];
    _quantity = json['quantity'];
    _unit = json['unit'];
    _servingDescription = json['servingDescription'];
    _metricServingAmount = json['metricServingAmount'];
    _metricServingUnit = json['metricServingUnit'];
    _numberOfUnits = json['numberOfUnits'];
    _measurementDescription = json['measurementDescription'];
    _saturatedFat = json['saturatedFat'];
    _polyunsaturatedFat = json['polyunsaturatedFat'];
    _monounsaturatedFat = json['monounsaturatedFat'];
    _vitaminA = json['vitaminA'];
    _vitaminC = json['vitaminC'];
  }

  String? _name;
  double? _calories;
  double? _protein;
  double? _fat;
  double? _carbs;
  double? _calcium;
  double? _cholesterol;
  double? _fiber;
  double? _iron;
  double? _potassium;
  double? _sodium;
  double? _sugar;
  double? _quantity;
  String? _unit;
  String? _servingDescription;
  String? _metricServingAmount;
  String? _metricServingUnit;
  String? _numberOfUnits;
  String? _measurementDescription;
  double? _saturatedFat;
  double? _polyunsaturatedFat;
  double? _monounsaturatedFat;
  double? _vitaminA;
  double? _vitaminC;

  ValueFood copyWith({
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? calcium,
    double? cholesterol,
    double? fiber,
    double? iron,
    double? potassium,
    double? sodium,
    double? sugar,
    double? quantity,
    String? unit,
    String? servingDescription,
    String? metricServingAmount,
    String? metricServingUnit,
    String? numberOfUnits,
    String? measurementDescription,
    double? saturatedFat,
    double? polyunsaturatedFat,
    double? monounsaturatedFat,
    double? vitaminA,
    double? vitaminC,
  }) =>
      ValueFood(
        name: name ?? _name,
        calories: calories ?? _calories,
        protein: protein ?? _protein,
        fat: fat ?? _fat,
        carbs: carbs ?? _carbs,
        calcium: calcium ?? _calcium,
        cholesterol: cholesterol ?? _cholesterol,
        fiber: fiber ?? _fiber,
        iron: iron ?? _iron,
        potassium: potassium ?? _potassium,
        sodium: sodium ?? _sodium,
        sugar: sugar ?? _sugar,
        quantity: quantity ?? _quantity,
        unit: unit ?? _unit,
        servingDescription: servingDescription ?? _servingDescription,
        metricServingAmount: metricServingAmount ?? _metricServingAmount,
        metricServingUnit: metricServingUnit ?? _metricServingUnit,
        numberOfUnits: numberOfUnits ?? _numberOfUnits,
        measurementDescription: measurementDescription ?? _measurementDescription,
        saturatedFat: saturatedFat ?? _saturatedFat,
        polyunsaturatedFat: polyunsaturatedFat ?? _polyunsaturatedFat,
        monounsaturatedFat: monounsaturatedFat ?? _monounsaturatedFat,
        vitaminA: vitaminA ?? _vitaminA,
        vitaminC: vitaminC ?? _vitaminC,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['calories'] = _calories;
    map['protein'] = _protein;
    map['fat'] = _fat;
    map['carbs'] = _carbs;
    map['calcium'] = _calcium;
    map['cholesterol'] = _cholesterol;
    map['fiber'] = _fiber;
    map['iron'] = _iron;
    map['potassium'] = _potassium;
    map['sodium'] = _sodium;
    map['sugar'] = _sugar;
    map['quantity'] = _quantity;
    map['unit'] = _unit;
    map['servingDescription'] = _servingDescription;
    map['metricServingAmount'] = _metricServingAmount;
    map['metricServingUnit'] = _metricServingUnit;
    map['numberOfUnits'] = _numberOfUnits;
    map['measurementDescription'] = _measurementDescription;
    map['saturatedFat'] = _saturatedFat;
    map['polyunsaturatedFat'] = _polyunsaturatedFat;
    map['monounsaturatedFat'] = _monounsaturatedFat;
    map['vitaminA'] = _vitaminA;
    map['vitaminC'] = _vitaminC;

    return map;
  }

  // Add getters for all the fields
  String? get name => _name;
  double? get calories => _calories;
  double? get protein => _protein;
  double? get fat => _fat;
  double? get carbs => _carbs;
  double? get calcium => _calcium;
  double? get cholesterol => _cholesterol;
  double? get fiber => _fiber;
  double? get iron => _iron;
  double? get potassium => _potassium;
  double? get sodium => _sodium;
  double? get sugar => _sugar;
  double? get quantity => _quantity;
  String? get unit => _unit;
  String? get servingDescription => _servingDescription;
  String? get metricServingAmount => _metricServingAmount;
  String? get metricServingUnit => _metricServingUnit;
  String? get numberOfUnits => _numberOfUnits;
  String? get measurementDescription => _measurementDescription;
  double? get saturatedFat => _saturatedFat;
  double? get polyunsaturatedFat => _polyunsaturatedFat;
  double? get monounsaturatedFat => _monounsaturatedFat;
  double? get vitaminA => _vitaminA;
  double? get vitaminC => _vitaminC;
}
