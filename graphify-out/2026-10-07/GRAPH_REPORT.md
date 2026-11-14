# Graph Report - aHealth  (2026-10-06)

## Corpus Check
- 239 files · ~107,951 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 45 file(s) not represented in the graph (top: .xml 11, .ttf 9, (none) 6)

## Summary
- 2075 nodes · 3378 edges · 125 communities (115 shown, 10 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Alignment Module
- Animationcontroller Module
- Core Database App Database ... Module
- Constants Dart Module
- Double Module
- Config Common Method Dart Module
- Custompainter Module
- Activity Factor Dart Module
- Annotation Pragma Module
- Models Food With Servings M... Module
- Bitmapdescriptor Module
- Helper Model Router Dart Module
- Domain Usecases Calculate D... Module
- Blocs Charts Calorie Chart ... Module
- Blocs Charts Water Chart Wa... Module
- Dart Ui Module
- Blocs Charts Step Chart Ste... Module
- Blocs Charts Height Chart H... Module
- Blocs Sleep Sleep Cubit Module
- Common Camera View Dart Module
- Blocs Nutrition Nutrition C... Module
- Presentation Common Widgets... Module
- Appcolors Dart Module
- Blocs Nutrition Nutrition C... Module
- Dart Async Module
- Blocs Chat Chat Cubit Dart Module
- Color Module
- Presentation Nutririon Food... Module
- Any Module
- Bloc Module
- Presentation Water Charts W... Module
- Features Step Tracking Data... Module
- Blocs Chat Chat Cubit Module
- Blocs Charts Nutrient Chart... Module
- Duration Module
- Cameracontroller Module
- Int Get Module
- Blocs Initialized Init App ... Module
- Presentation Steps Monthly Tab Module
- Presentation Nutririon Nitr... Module
- Presentation Nutririon Widg... Module
- Presentation Steps Widgets ... Module
- Services Chat Hive Service Module
- Dart Convert Module
- Dart Typed Data Module
- Datetime Module
- Entities Activity Dart Module
- Blocs Charts Calorie Chart ... Module
- Features Progress Photos Pr... Module
- Models Height Model Module
- Models Sleep Model Module
- Blocs Initialized Init App ... Module
- Dart Developer Module
- Entities Streak Entity Dart Module
- Features Progress Photos Pr... Module
- Features Streak Domain Enti... Module
- Blocs Charts Nutrient Chart... Module
- Common Spring Button Widget... Module
- Models Food Search Model Module
- Models Step Model Module
- Models Water Model Module
- Models Weightmodel Module
- Presentation Home Widget Sl... Module
- Blocs Food Search Food Sear... Module
- Blocs Sleep Sleep Cubit Sle... Module
- Blocs Step Step Cubit Module
- Constants Module
- Models Chat Chat Message Model Module
- Add Edit Entry Screen Dart Module
- Annotation Hivetype Module
- Blocs Height Height Cubit Dart Module
- Datetime Start Module
- Globalkey Module
- Blocs Height Height Cubit Module
- Models Nutrition Model Valu... Module
- Presentation Onboarding Onb... Module
- Blocs Sleep Sleep Cubit Dart Module
- Entities Location Point Dart Module
- Int Module
- Appcolors Module
- Blocs Fooddetail Food Detai... Module
- Models Chat Chat Session Model Module
- Presentation Nutririon Widg... Module
- Features Progress Photos Pr... Module
- Features Step Tracking Doma... Module
- Presentation Steps Widgets ... Module
- Services Nutrition Service Module
- Blocs Charts Calorie Chart ... Module
- Blocs Weight Weight Cubit Dart Module
- Cubit Streak Cubit Dart Module
- Features Progress Photos Do... Module
- Features Progress Photos Pr... Module
- Features Streak Presentatio... Module
- Models Value Model Module
- Presentation Home Home Widg... Module
- Blocs Step Step Cubit Dart Module
- Datasources Tracking Local ... Module
- Domain Entities Streak Enti... Module
- File Module
- Blocs Food Scan Food Scan C... Module
- Helper Model Router Module
- Presentation Nutririon Widg... Module
- Presentation Onboarding Get... Module
- Blocs Food Scan Food Scan C... Module
- Dart Io Module
- Domain Entities Progress En... Module
- Domain Usecases Get Streak ... Module
- Cubit Module
- Equatable Module
- Datasources Streak Local Da... Module
- Features Progress Photos Pr... Module
- Features Progress Photos Pr... Module
- Domain Entities Activity Dart Module
- Domain Entities Location Po... Module
- Double Get Module
- Android App Src Main Kotlin... Module
- Config Appconstants Module
- Features Step Tracking Pres... Module
- Config Appenums Module
- Presentation Profileinfo He... Module

## God Nodes (most connected - your core abstractions)
1. `NutritionCubit` - 34 edges
2. `FoodScanCubit` - 18 edges
3. `TrackingCubit` - 17 edges
4. `SleepCubit` - 16 edges
5. `WaterCubit` - 16 edges
6. `StreakCubit` - 16 edges
7. `WeightCubit` - 15 edges
8. `ProgressBloc` - 15 edges
9. `InitAppCubit` - 14 edges
10. `StepsCubit` - 13 edges

## Surprising Connections (you probably didn't know these)
- `build` --references--> `FoodSearchCubit`  [EXTRACTED]
  lib/presentation/searchscreen.dart → lib/blocs/food_search/food_search_cubit.dart
- `initState` --references--> `FoodDetailCubit`  [EXTRACTED]
  lib/presentation/nutririon/fooddetailscreen.dart → lib/blocs/fooddetail/food_detail_cubit.dart
- `showHeightDialog` --references--> `HeightCubit`  [EXTRACTED]
  lib/helper/helper_func.dart → lib/blocs/height/height_cubit.dart
- `build` --references--> `NutritionCubit`  [EXTRACTED]
  lib/presentation/home.dart → lib/blocs/nutrition/nutrition_cubit.dart
- `build` --references--> `NutritionCubit`  [EXTRACTED]
  lib/presentation/nutririon/calorie_chart_screen.dart → lib/blocs/nutrition/nutrition_cubit.dart

## Import Cycles
- None detected.

## Communities (125 total, 10 thin omitted)

### Community 0 - "Alignment Module"
Cohesion: 0.02
Nodes (64): alignment, animation, animationController, build, createState, _debugLevel, disable, dispose (+56 more)

### Community 1 - "Animationcontroller Module"
Cohesion: 0.06
Nodes (37): addWater, decreaseLastWaterData, getWaterData, WaterCubit, build, HydrationCard, _kOnSurfaceVariant, _kSurfaceContainerLowest (+29 more)

### Community 2 - "Core Database App Database ... Module"
Cohesion: 0.05
Nodes (32): AppDatabase, _db, _initDb, instance, database, deleteEntry, getAllEntries, insertEntry (+24 more)

### Community 3 - "Constants Dart Module"
Cohesion: 0.05
Nodes (41): activityLabel, bmr, calculate, carbs, fat, NutritionTargets, protein, target (+33 more)

### Community 4 - "Double Module"
Cohesion: 0.05
Nodes (36): _calcium, _calories, _carbs, _cholesterol, copyWith, _dateFrom, _dateTo, _fat (+28 more)

### Community 5 - "Config Common Method Dart Module"
Cohesion: 0.12
Nodes (30): getDataFromNow, HeightChartCubit, getDataFromNow, SleepChartCubit, getDataFromNow, WeightChartCubit, dataMonth, dataWeek (+22 more)

### Community 6 - "Custompainter Module"
Cohesion: 0.06
Nodes (33): _PathPainter, BottomIndicatorPainter, build, createState, didChangeDependencies, didUpdateWidget, dispose, IndicatorPainter (+25 more)

### Community 7 - "Activity Factor Dart Module"
Cohesion: 0.05
Nodes (33): activityLevelCard, activityLevelWidget, age, ageWidget, build, createState, dispose, Gender (+25 more)

### Community 8 - "Annotation Pragma Module"
Cohesion: 0.05
Nodes (26): build, isMoving, RunnerMarker, build, _addHours, cancelAll, cancelMealReminders, cancelWaterReminders (+18 more)

### Community 9 - "Models Food With Servings M... Module"
Cohesion: 0.06
Nodes (35): calcium, calories, carbohydrate, cholesterol, copyWith, fat, fiber, foodId (+27 more)

### Community 10 - "Bitmapdescriptor Module"
Cohesion: 0.06
Nodes (25): _bearingDiff, _calculateHeading, createState, _currentZoom, dispose, _fallbackCenter, _initialCenter, initState (+17 more)

### Community 11 - "Helper Model Router Dart Module"
Cohesion: 0.06
Nodes (11): getStart, heathDetail, home, onBoarding, permissionError, rootNavigatorKey, router, sdkError (+3 more)

### Community 12 - "Domain Usecases Calculate D... Module"
Cohesion: 0.06
Nodes (23): _accuracyThreshold, _activityId, _batchSize, calculateDistance, close, _distance, _elapsed, _emitActive (+15 more)

### Community 13 - "Blocs Charts Calorie Chart ... Module"
Cohesion: 0.07
Nodes (19): dateLabel, build, CalorieLineChart, _consumedColor, _fmt, label, points, _targetColor (+11 more)

### Community 14 - "Blocs Charts Water Chart Wa... Module"
Cohesion: 0.11
Nodes (22): getChartData, getMonthData, _getWaterBatch, getWeekData, WaterChartCubit, build, createState, dispose (+14 more)

### Community 15 - "Dart Ui Module"
Cohesion: 0.08
Nodes (24): CupertinoBackButton, NutritionDetailScreen, build, CardShell, child, _AnimatedCard, child, color (+16 more)

### Community 16 - "Blocs Charts Step Chart Ste... Module"
Cohesion: 0.12
Nodes (20): getDataFromNow, StepChartCubit, build, createState, dispose, initState, kDailyTarget, _selectedTab (+12 more)

### Community 17 - "Blocs Charts Height Chart H... Module"
Cohesion: 0.08
Nodes (11): build, child, _ConfettiOverlay, _ConfettiOverlayState, _controller, createState, dispose, init (+3 more)

### Community 18 - "Blocs Sleep Sleep Cubit Module"
Cohesion: 0.11
Nodes (22): addSleep, asleep, calculateSleepScore, deepPct, deleteToadySleepData, durationScore, efficiencyScore, endTime (+14 more)

### Community 19 - "Common Camera View Dart Module"
Cohesion: 0.09
Nodes (11): _bg, _carbsColor, _card, createState, _fatColor, _groupItems, Nutrition, _NutritionState (+3 more)

### Community 20 - "Blocs Nutrition Nutrition C... Module"
Cohesion: 0.14
Nodes (21): addMultipleNutritionData, addNutritionData, _cache, _dayKey, _getMealType, getNutritionData, invalidateCache, _mgToG (+13 more)

### Community 21 - "Presentation Common Widgets... Module"
Cohesion: 0.09
Nodes (13): build, children, currentSelection, CustomSlidingSegmentedControl, icons, thumbColor, build, loaded (+5 more)

### Community 22 - "Appcolors Dart Module"
Cohesion: 0.09
Nodes (11): build, createState, HomeWidget, _HomeWidgetState, initState, _kOnSurfaceVariant, _kSurfaceContainerLowest, _loadUserImage (+3 more)

### Community 23 - "Blocs Nutrition Nutrition C... Module"
Cohesion: 0.09
Nodes (16): build, BuildCardContent, _carbsColor, count, _fatColor, groupItems, item, _proteinColor (+8 more)

### Community 24 - "Dart Async Module"
Cohesion: 0.11
Nodes (20): _apiKey, _canScanToday, _csvHeaders, _fallbackModels, _maxScansPerDay, _parseCsv, _prompt, _scanCountKey (+12 more)

### Community 25 - "Blocs Chat Chat Cubit Dart Module"
Cohesion: 0.09
Nodes (18): _bg, _buildBubble, _buildEmptyState, _buildInputBar, _buildTypingIndicator, _card, chats, _controller (+10 more)

### Community 26 - "Color Module"
Cohesion: 0.10
Nodes (17): build, CircularProgress, color, icon, iconColor, size, value, build (+9 more)

### Community 27 - "Presentation Nutririon Food... Module"
Cohesion: 0.10
Nodes (21): _bg, build, _buildMacroText, _buildSummaryChip, _carbsColor, _card, createState, _fatColor (+13 more)

### Community 28 - "Any Module"
Cohesion: 0.10
Nodes (7): Flutter, flutter_local_notifications, AppDelegate, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 29 - "Bloc Module"
Cohesion: 0.16
Nodes (15): ProgressRepository, _onAdd, _onDelete, _onEdit, _onLoad, ProgressBloc, repository, AddProgressEntry (+7 more)

### Community 30 - "Presentation Water Charts W... Module"
Cohesion: 0.10
Nodes (15): build, createState, initState, label, points, _trackball, WaterBarChart, _WaterBarChartState (+7 more)

### Community 31 - "Features Step Tracking Data... Module"
Cohesion: 0.10
Nodes (6): localDataSource, repository, setupLocator, sl, streakLocalDataSource, streakRepository

### Community 32 - "Blocs Chat Chat Cubit Module"
Cohesion: 0.15
Nodes (16): _apiKey, clearChat, _currentSessionId, _messages, _fallbackModels, loadSession, sendMessage, startNewSession (+8 more)

### Community 33 - "Blocs Charts Nutrient Chart... Module"
Cohesion: 0.11
Nodes (15): _carbs, color, _confs, createState, currentTab, _fat, label, NutrientChartScreen (+7 more)

### Community 34 - "Duration Module"
Cohesion: 0.16
Nodes (17): TrackingCubit, activity, distanceMeters, elapsed, paceSecPerKm, points, props, TrackingActive (+9 more)

### Community 35 - "Cameracontroller Module"
Cohesion: 0.12
Nodes (14): build, cameras, CameraScreen, _CameraScreenState, _capture, _controller, createState, dispose (+6 more)

### Community 36 - "Int Get Module"
Cohesion: 0.17
Nodes (15): foods, FoodScanGroup, fromValueFood, imagePath, timestamp, toValueFood, uuid, ValueFoodHive (+7 more)

### Community 37 - "Blocs Initialized Init App ... Module"
Cohesion: 0.19
Nodes (12): checkPermissions, initializeHealthSdk, installHealthConnect, prefs, types, InitAppFailed, InitAppLoading, InitAppPermissionNotAvailable (+4 more)

### Community 38 - "Presentation Steps Monthly Tab Module"
Cohesion: 0.13
Nodes (10): build, _fmt, _fmtK, loaded, monthData, MonthlyTab, build, _fmt (+2 more)

### Community 39 - "Presentation Nutririon Nitr... Module"
Cohesion: 0.12
Nodes (15): _bg, build, _buildListTile, _buildSectionHeader, _carbsColor, _fatColor, _iOSListGroup, _microColor (+7 more)

### Community 40 - "Presentation Nutririon Widg... Module"
Cohesion: 0.12
Nodes (12): _controller, createState, dispose, _editing, FoodVoiceInputSheet, _FoodVoiceInputSheetState, initState, _isListening (+4 more)

### Community 41 - "Presentation Steps Widgets ... Module"
Cohesion: 0.12
Nodes (10): build, SummaryCards, build, color, dashed, label, LegendDot, build (+2 more)

### Community 42 - "Services Chat Hive Service Module"
Cohesion: 0.12
Nodes (12): ChatHiveService, deleteSession, getMessages, getSessions, instance, _messages, _messagesBox, openBoxes (+4 more)

### Community 43 - "Dart Convert Module"
Cohesion: 0.26
Nodes (11): _baseUrl, FoodSearchCubit, searchFood, errorMessage, FoodSearchFailed, FoodSearchInitailize, FoodSearchLoading, foodSearchModel (+3 more)

### Community 44 - "Dart Typed Data Module"
Cohesion: 0.12
Nodes (13): boundary, build, byteData, captureCardAsPng, image, JourneyShareCard, km, paint (+5 more)

### Community 45 - "Datetime Module"
Cohesion: 0.12
Nodes (12): CaloriePoint, consumed, date, target, tdee, date, NutrientPoint, value (+4 more)

### Community 46 - "Entities Activity Dart Module"
Cohesion: 0.15
Nodes (11): TrackingRepositoryImpl, TrackingRepository, call, GetActivities, repo, call, GetLocationStream, repo (+3 more)

### Community 47 - "Blocs Charts Calorie Chart ... Module"
Cohesion: 0.27
Nodes (13): CalorieChartCubit, getWeekData, initState, CalorieChartFailed, CalorieChartLoading, CalorieChartState, CalorieChartSuccess, consumed (+5 more)

### Community 48 - "Features Progress Photos Pr... Module"
Cohesion: 0.12
Nodes (15): AddEditEntryScreen, build, createState, _date, dispose, existing, _fieldCard, initState (+7 more)

### Community 49 - "Models Height Model Module"
Cohesion: 0.12
Nodes (14): copyWith, _dateFrom, _dateTo, HeightModel, _recordingMethod, _sourceDeviceId, _sourceId, _sourceName (+6 more)

### Community 50 - "Models Sleep Model Module"
Cohesion: 0.12
Nodes (14): copyWith, _dateFrom, _dateTo, _recordingMethod, SleepModel, _sourceDeviceId, _sourceId, _sourceName (+6 more)

### Community 51 - "Blocs Initialized Init App ... Module"
Cohesion: 0.19
Nodes (7): AppRoutes, appTheme, InitAppCubit, build, PermissionErrorScreem, build, SdkErrorScreen

### Community 52 - "Dart Developer Module"
Cohesion: 0.13
Nodes (10): end, endOfDay, getDataForDay, getDataForDaysBatch, result, start, startOfDay, total (+2 more)

### Community 53 - "Entities Streak Entity Dart Module"
Cohesion: 0.16
Nodes (10): StreakRepositoryImpl, getStreak, logActivity, StreakRepository, call, GetStreakUsecase, repository, call (+2 more)

### Community 54 - "Features Progress Photos Pr... Module"
Cohesion: 0.14
Nodes (10): build, child, createState, dispose, HomeScreen, _HomeScreenState, _locationToIndex, _onAndroidBack (+2 more)

### Community 55 - "Features Streak Domain Enti... Module"
Cohesion: 0.27
Nodes (10): addWeight, getWeightData, WeightCubit, errorMessage, props, WeightFailed, WeightLoading, weightModel (+2 more)

### Community 56 - "Blocs Charts Nutrient Chart... Module"
Cohesion: 0.28
Nodes (12): getWeekData, NutrientChartCubit, NutrientType, initState, errorMessage, NutrientChartFailed, NutrientChartLoading, NutrientChartState (+4 more)

### Community 57 - "Common Spring Button Widget... Module"
Cohesion: 0.20
Nodes (12): SpringButton, SpringButtonState, _ThinkingBlock, _ThinkingBlockState, _TypingDots, _TypingDotsState, CalorieChartScreen, _CalorieChartScreenState (+4 more)

### Community 58 - "Models Food Search Model Module"
Cohesion: 0.18
Nodes (13): copyWith, foodDescription, foodId, foodName, FoodSearchModel, foodType, foodUrl, toJson (+5 more)

### Community 59 - "Models Step Model Module"
Cohesion: 0.13
Nodes (14): copyWith, _dateFrom, _dateTo, _recordingMethod, _sourceDeviceId, _sourceId, _sourceName, _sourcePlatform (+6 more)

### Community 60 - "Models Water Model Module"
Cohesion: 0.13
Nodes (14): copyWith, _dateFrom, _dateTo, _recordingMethod, _sourceDeviceId, _sourceId, _sourceName, _sourcePlatform (+6 more)

### Community 61 - "Models Weightmodel Module"
Cohesion: 0.13
Nodes (14): copyWith, _dateFrom, _dateTo, _recordingMethod, _sourceDeviceId, _sourceId, _sourceName, _sourcePlatform (+6 more)

### Community 62 - "Presentation Home Widget Sl... Module"
Cohesion: 0.13
Nodes (13): _bedTime, build, _formatClock, h, _kOnSurfaceVariant, _kPrimary, _kSurfaceContainerLowest, _kTertiary (+5 more)

### Community 63 - "Blocs Food Search Food Sear... Module"
Cohesion: 0.15
Nodes (8): build, createState, initialized, initState, isTextEmpty, searchFoodBox, SearchFoodScreen, _SearchFoodScreenState

### Community 64 - "Blocs Sleep Sleep Cubit Sle... Module"
Cohesion: 0.18
Nodes (13): SleepCubit, _dialogButton, from, loadData, picked, selectTime, showCustomDialog, showDialog (+5 more)

### Community 65 - "Blocs Step Step Cubit Module"
Cohesion: 0.30
Nodes (11): getStepData, getTodayStep, StepsCubit, MyApp, errorMessage, props, StepFailed, StepLoadingState (+3 more)

### Community 66 - "Constants Module"
Cohesion: 0.14
Nodes (13): activityLevel, age, gender, healthGoal, healthSdkSharedPreferenceKey, height, heightUnit, isOnBoardingSharedPreferenceKey (+5 more)

### Community 67 - "Models Chat Chat Message Model Module"
Cohesion: 0.22
Nodes (12): ChatMessage, isUser, sessionId, text, thinkingText, time, ChatMessageAdapter, hashCode (+4 more)

### Community 68 - "Add Edit Entry Screen Dart Module"
Cohesion: 0.17
Nodes (6): _card, createState, progressPhotos, ProgressPhotosScreen, _ProgressPhotosScreenState, screenshotController

### Community 69 - "Annotation Hivetype Module"
Cohesion: 0.24
Nodes (10): Foods, Food, FoodWithServingsModel, Serving, Servings, FoodsAdapter, FoodAdapter, FoodWithServingsModelAdapter (+2 more)

### Community 70 - "Blocs Height Height Cubit Dart Module"
Cohesion: 0.17
Nodes (10): build, createState, HeightCard, _HeightCardState, _kOnSurfaceVariant, _kPrimary, _kSurfaceContainerHighest, _kSurfaceContainerLowest (+2 more)

### Community 71 - "Datetime Start Module"
Cohesion: 0.15
Nodes (7): avg, end, WaterWeekSummary, weekNum, build, summary, WaterWeekTile

### Community 72 - "Globalkey Module"
Cohesion: 0.17
Nodes (7): createState, _shareCardKey, _shareKm, _shareLatLngs, _shareTime, TrackingHistoryView, _TrackingHistoryViewState

### Community 73 - "Blocs Height Height Cubit Module"
Cohesion: 0.33
Nodes (10): addHeight, getHeight, HeightCubit, errorMessage, HeightFailed, HeightLoading, heightModel, HeightState (+2 more)

### Community 74 - "Models Nutrition Model Valu... Module"
Cohesion: 0.17
Nodes (10): ValueFood, build, createState, FoodDetailScreen, _FoodDetailScreenState, foodId, initState, multiplier (+2 more)

### Community 75 - "Presentation Onboarding Onb... Module"
Cohesion: 0.17
Nodes (9): build, createState, currentIndex, dispose, onBoardingData, OnboardingScreen, _OnboardingScreenState, _pageController (+1 more)

### Community 76 - "Blocs Sleep Sleep Cubit Dart Module"
Cohesion: 0.18
Nodes (9): build, _buildTimeHeader, _calculateTotalSleep, createState, _endTime, _formatTimeText, SleepPickerBottomSheet, _SleepPickerBottomSheetState (+1 more)

### Community 77 - "Entities Location Point Dart Module"
Cohesion: 0.18
Nodes (7): getActivities, getPointsForActivity, positionStream, saveActivity, savePointsBatch, CalculateDistance, call

### Community 78 - "Int Module"
Cohesion: 0.17
Nodes (10): accuracy, activityId, altitude, copyWith, id, lat, lng, props (+2 more)

### Community 79 - "Appcolors Module"
Cohesion: 0.17
Nodes (11): appWhite, background, black, darkGrey, grey, greyBackground, primary, red (+3 more)

### Community 80 - "Blocs Fooddetail Food Detai... Module"
Cohesion: 0.41
Nodes (10): fetchFoodDetails, FoodDetailCubit, errorMessage, FoodDetailFailed, FoodDetailInitial, FoodDetailLoading, FoodDetailState, FoodDetailSuccess (+2 more)

### Community 81 - "Models Chat Chat Session Model Module"
Cohesion: 0.27
Nodes (10): ChatSession, createdAt, id, title, ChatSessionAdapter, hashCode, operator, read (+2 more)

### Community 82 - "Presentation Nutririon Widg... Module"
Cohesion: 0.17
Nodes (11): build, _card, color, icon, label, MacroCard, progress, _textPrimary (+3 more)

### Community 83 - "Features Progress Photos Pr... Module"
Cohesion: 0.18
Nodes (7): build, controller, entries, generateAndSave, month, _monthEntries, MonthlyCollage

### Community 84 - "Features Step Tracking Doma... Module"
Cohesion: 0.18
Nodes (10): ActivityType, avgPaceSecPerKm, calories, distanceMeters, durationSeconds, endTime, id, props (+2 more)

### Community 85 - "Presentation Steps Widgets ... Module"
Cohesion: 0.18
Nodes (10): avg, build, end, _fmt, start, summary, total, WeekListTile (+2 more)

### Community 86 - "Services Nutrition Service Module"
Cohesion: 0.18
Nodes (7): deleteGroup, _foodScanGroupBox, getAllGroups, init, NutritionService, saveScanGroup, _uuid

### Community 87 - "Blocs Charts Calorie Chart ... Module"
Cohesion: 0.20
Nodes (4): build, createState, pageName, _textPrimary

### Community 88 - "Blocs Weight Weight Cubit Dart Module"
Cohesion: 0.20
Nodes (6): build, build, _kOnSurfaceVariant, _kPrimary, _kSurfaceContainerLowest, WeightCard

### Community 89 - "Cubit Streak Cubit Dart Module"
Cohesion: 0.22
Nodes (6): build, createState, initState, pageName, StreakScreen, _StreakScreenState

### Community 90 - "Features Progress Photos Do... Module"
Cohesion: 0.20
Nodes (8): copyWith, date, fromMap, id, photoPath, props, toMap, weight

### Community 91 - "Features Progress Photos Pr... Module"
Cohesion: 0.20
Nodes (8): build, entries, maxY, minY, sorted, spots, WeightChart, weights

### Community 92 - "Features Streak Presentatio... Module"
Cohesion: 0.40
Nodes (9): StreakCubit, message, streak, StreakCelebration, StreakError, StreakInitial, StreakLoaded, StreakLoading (+1 more)

### Community 93 - "Models Value Model Module"
Cohesion: 0.20
Nodes (5): copyWith, _numericValue, toJson, _type, Value

### Community 94 - "Presentation Home Home Widg... Module"
Cohesion: 0.20
Nodes (4): _buildTopBar, build, build, build

### Community 95 - "Blocs Step Step Cubit Dart Module"
Cohesion: 0.22
Nodes (6): build, _kOnSurfaceVariant, _kPrimary, _kPrimaryContainer, _kSurfaceContainerHighest, StepsCard

### Community 96 - "Datasources Tracking Local ... Module"
Cohesion: 0.22
Nodes (6): getActivities, getPointsForActivity, local, positionStream, saveActivity, savePointsBatch

### Community 97 - "Domain Entities Streak Enti... Module"
Cohesion: 0.22
Nodes (6): fromEntity, StreakModel, currentStreak, longestStreak, StreakActivityType, StreakEntity

### Community 98 - "File Module"
Cohesion: 0.22
Nodes (7): date, entry, existing, image, newImage, props, weight

### Community 99 - "Blocs Food Scan Food Scan C... Module"
Cohesion: 0.36
Nodes (9): FoodScanCubit, _submit, FoodScanError, FoodScanInitial, FoodScanLoading, FoodScanNoItems, FoodScanState, FoodScanSuccess (+1 more)

### Community 100 - "Helper Model Router Module"
Cohesion: 0.25
Nodes (5): barrierColor, builder, createRoute, isScrollControlled, ModalSheetPage

### Community 101 - "Presentation Nutririon Widg... Module"
Cohesion: 0.22
Nodes (7): build, color, _fmt, label, NutrientLineChart, points, unit

### Community 102 - "Presentation Onboarding Get... Module"
Cohesion: 0.25
Nodes (4): build, createState, GetStartingScreen, _GetStartingScreenState

### Community 103 - "Blocs Food Scan Food Scan C... Module"
Cohesion: 0.25
Nodes (5): FoodScanLoadingSheet, _sheetBg, _sheetCard, _sheetTextPrimary, _sheetTextSecondary

### Community 104 - "Dart Io Module"
Cohesion: 0.25
Nodes (4): NutritionModel, build, FoodImage, item

### Community 105 - "Domain Entities Progress En... Module"
Cohesion: 0.25
Nodes (6): copyWith, entries, errorMessage, ProgressStatus, props, status

### Community 106 - "Domain Usecases Get Streak ... Module"
Cohesion: 0.25
Nodes (4): getStreakUsecase, loadStreak, logActivityAndRefresh, logActivityUsecase

### Community 107 - "Cubit Module"
Cohesion: 0.29
Nodes (6): ChatCubit, build, _buildDrawer, ChatWidget, _ChatWidgetState, _send

### Community 108 - "Equatable Module"
Cohesion: 0.29
Nodes (6): ProgressEntry, ProgressState, ActivityModel, LocationPointModel, Activity, LocationPoint

### Community 109 - "Datasources Streak Local Da... Module"
Cohesion: 0.33
Nodes (3): getStreak, localDataSource, logActivity

### Community 110 - "Features Progress Photos Pr... Module"
Cohesion: 0.33
Nodes (5): build, build, build, build, searchFoodCard

### Community 111 - "Features Progress Photos Pr... Module"
Cohesion: 0.33
Nodes (3): _kOnSurfaceVariant, _kPrimary, ProgressCard

### Community 112 - "Domain Entities Activity Dart Module"
Cohesion: 0.40
Nodes (3): fromEntity, fromMap, toMap

### Community 113 - "Domain Entities Location Po... Module"
Cohesion: 0.40
Nodes (3): fromEntity, fromMap, toMap

### Community 114 - "Double Get Module"
Cohesion: 0.50
Nodes (3): ActivityLevel, ActivityLevelFactor, factor

## Knowledge Gaps
- **1073 isolated node(s):** `flutter_local_notifications`, `XCTest`, `getStart`, `permissionError`, `sdkError` (+1068 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 1294 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `StreakCubit` connect `Features Streak Presentatio... Module` to `Animationcontroller Module`, `Domain Usecases Get Streak ... Module`, `Cubit Module`, `Blocs Charts Height Chart H... Module`, `Blocs Nutrition Nutrition C... Module`, `Appcolors Dart Module`, `Features Streak Domain Enti... Module`, `Cubit Streak Cubit Dart Module`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `flutter_local_notifications`, `XCTest`, `getStart` to the rest of the system?**
  _1073 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Alignment Module` be split into smaller, more focused modules?**
  _Cohesion score 0.02247191011235955 - nodes in this community are weakly interconnected._
- **Why does `NutritionModel` connect `Dart Io Module` to `Dart Ui Module`, `Double Module`, `Blocs Nutrition Nutrition C... Module`, `Presentation Nutririon Nitr... Module`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `Animationcontroller Module` be split into smaller, more focused modules?**
  _Cohesion score 0.05959183673469388 - nodes in this community are weakly interconnected._
- **Why does `TrackingRepository` connect `Entities Activity Dart Module` to `Domain Usecases Calculate D... Module`, `Entities Location Point Dart Module`, `Features Step Tracking Data... Module`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `Core Database App Database ... Module` be split into smaller, more focused modules?**
  _Cohesion score 0.04846938775510204 - nodes in this community are weakly interconnected._