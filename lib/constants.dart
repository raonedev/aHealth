const String healthSdkSharedPreferenceKey='healthSdkValue';
const String isOnBoardingSharedPreferenceKey='isOnBoardingComplete';

class PrefKeys {
  static const String userName = 'userNameSharedPreferenceKey';
  static const String profileImagePath = 'userProfileImagePathSharedPreferenceKey';
  static const String weight = 'userWeightSharedPreferenceKey';
  static const String weightUnit = 'userWeightUnitSharedPreferenceKey';
  static const String height = 'userHeightSharedPreferenceKey';
  static const String heightUnit = 'userHeightUnitSharedPreferenceKey';
  static const String gender = 'userGenderSharedPreferenceKey';
  static const String healthGoal = 'userHealthGoalSharedPreferenceKey';
  static const String age = 'userAgeSharedPreferenceKey';
  static const String activityLevel = 'userActivityLevelSharedPreferenceKey';
  static const String waterLogAmountMl = 'userWaterLogAmountMlSharedPreferenceKey';
  static const String targetSteps = 'userTargetStepsSharedPreferenceKey';
  static const String targetWaterLiters = 'userTargetWaterLitersSharedPreferenceKey';
}

const int kDefaultWaterLogAmountMl = 250;
const int kDefaultTargetSteps = 8000;
const double kDefaultTargetWaterLiters = 3.0;