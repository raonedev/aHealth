enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extraActive }

extension ActivityLevelFactor on ActivityLevel {
  double get factor => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.lightlyActive => 1.375,
        ActivityLevel.moderatelyActive => 1.55,
        ActivityLevel.veryActive => 1.725,
        ActivityLevel.extraActive => 1.9,
      };
}