
class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficulty;
  final String shortDescription;
  final String instructions;
  final List<String> steps;
  final List<String> formCues;
  final String? maleVideo;
  final String? femaleVideo;
  final String? maleThumbnail;
  final String? femaleThumbnail;

  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    this.shortDescription = '',
    this.instructions = '',
    this.steps = const [],
    this.formCues = const [],
    this.maleVideo,
    this.femaleVideo,
    this.maleThumbnail,
    this.femaleThumbnail,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final v = json['videos'] as Map<String, dynamic>?;
    final t = json['thumbnails'] as Map<String, dynamic>?;
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bodyPart: json['bodyPart']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      secondaryMuscles: (json['secondaryMuscles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      equipment: json['equipment']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      steps: (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
      formCues: (json['formCues'] as List?)?.map((e) => e.toString()).toList() ?? [],
      maleVideo: v?['male']?.toString(),
      femaleVideo: v?['female']?.toString(),
      maleThumbnail: t?['male']?.toString(),
      femaleThumbnail: t?['female']?.toString(),
    );
  }
}

class PlannedExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final int sets;
  final int reps;
  final double weightKg;
  final int restSeconds;

  const PlannedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    this.sets = 3,
    this.reps = 10,
    this.weightKg = 0.0,
    this.restSeconds = 60,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'bodyPart': bodyPart,
    'sets': sets,
    'reps': reps,
    'weightKg': weightKg,
    'restSeconds': restSeconds,
  };

  factory PlannedExercise.fromJson(Map<String, dynamic> map) {
    return PlannedExercise(
      id: map['id']?.toString() ?? '',
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      bodyPart: map['bodyPart']?.toString() ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
    );
  }
}

class WorkoutLog {
  final String id;
  final String exerciseName;
  final String bodyPart;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final int setsCompleted;
  final int reps;
  final double weightKg;
  final bool syncedHealthConnect;

  const WorkoutLog({
    required this.id,
    required this.exerciseName,
    required this.bodyPart,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.setsCompleted,
    required this.reps,
    required this.weightKg,
    this.syncedHealthConnect = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseName': exerciseName,
    'bodyPart': bodyPart,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'setsCompleted': setsCompleted,
    'reps': reps,
    'weightKg': weightKg,
    'syncedHealthConnect': syncedHealthConnect,
  };

  factory WorkoutLog.fromJson(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      bodyPart: map['bodyPart']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 15,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 100,
      setsCompleted: (map['setsCompleted'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      syncedHealthConnect: map['syncedHealthConnect'] == true,
    );
  }

  WorkoutLog copyWith({
    String? id,
    String? exerciseName,
    String? bodyPart,
    DateTime? date,
    int? durationMinutes,
    int? caloriesBurned,
    int? setsCompleted,
    int? reps,
    double? weightKg,
    bool? syncedHealthConnect,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      bodyPart: bodyPart ?? this.bodyPart,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      syncedHealthConnect: syncedHealthConnect ?? this.syncedHealthConnect,
    );
  }
}
