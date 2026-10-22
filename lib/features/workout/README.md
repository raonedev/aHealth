# Workout Feature Architecture & Flow

This directory (`lib/features/workout/`) implements a complete offline-first, video-guided workout planning, logging, and Android Health Connect integration system.

---

## 1. System Overview

```
                          assets/exercise.json (317 Exercises)
                          assets/front.svg & assets/back.svg
                                        │
                                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                              WorkoutService                                  │
│  - Asset loader & caching             - Health Connect (Health package)      │
│  - Weekly plan persistence (Prefs)    - Session logs persistence (Prefs)     │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                ▼                      ▼                      ▼
       ┌─────────────────┐   ┌───────────────────┐   ┌─────────────────┐
       │   Weekly Plan   │   │  Explore & Body   │   │     History     │
       │     (Tab 1)     │   │      (Tab 2)      │   │     (Tab 3)     │
       └────────┬────────┘   └─────────┬─────────┘   └────────┬────────┘
                │                      │                      │
                │              ┌───────┴────────┐             │
                ▼              ▼                ▼             ▼
       ┌─────────────────┐ ┌──────────────┐ ┌─────────────┐ ┌─────────────────┐
       │ BreakTimerWidget│ │BodyMapWidget │ │ExerciseCard │ │Edit / Delete Log│
       └─────────────────┘ └──────────────┘ └──────┬──────┘ └─────────────────┘
                                                   │
                                                   ▼
                                      ┌────────────────────────┐
                                      │  ExerciseDetailDialog  │
                                      │  - Looping Video Player│
                                      │  - Gender Switcher     │
                                      │  - Add to Weekly Plan  │
                                      │  - Quick Log to Health │
                                      └────────────────────────┘
```

---

## 2. Directory Structure

```
lib/features/workout/
├── models/
│   └── workout_models.dart         # Exercise, PlannedExercise, and WorkoutLog data models
├── presentation/
│   ├── screens/
│   │   └── workout_screen.dart     # Main 3-tab screen (Plan, Explore, History)
│   └── widgets/
│       ├── body_map_widget.dart    # SVG body anatomy colorizer & interactive target selector
│       ├── break_timer_widget.dart # Rest interval countdown timer with presets & haptics
│       └── exercise_detail_dialog.dart # Video player modal, plan adder, & quick logger
├── services/
│   └── workout_service.dart        # Data access layer, SharedPreferences, & Health Connect API
└── README.md                       # Complete documentation of the workout flow
```

---

## 3. Core Components & Responsibilities

### A. Data Models (`models/workout_models.dart`)
1. **`Exercise`**:
   - Represents an exercise loaded from `assets/exercise.json`.
   - Contains names, body parts, primary & secondary muscles, equipment, difficulty, steps, form cues, and male/female video & thumbnail CDN URLs.
2. **`PlannedExercise`**:
   - Represents an exercise scheduled for a specific day of the week (1 = Monday ... 7 = Sunday).
   - Stores target sets, reps, weight (kg), and rest duration (seconds).
3. **`WorkoutLog`**:
   - Represents a completed workout session with timestamp, duration (minutes), calories burned, sets completed, reps, weight (kg), and Health Connect sync status.
   - Includes a `copyWith()` helper for in-place editing in History.

---

### B. Service Layer (`services/workout_service.dart`)
- **Asset Loading**: Caches the 317 exercises in memory after the first read from `assets/exercise.json`.
- **Local Weekly Plan**: Keyed in `SharedPreferences` by `workout_weekly_plan`. Allows getting, adding, and removing planned exercises per day of the week.
- **Local Workout Logs**: Keyed in `SharedPreferences` by `workout_logs_history`. Stores session records in descending chronological order.
- **Health Connect Integration**:
  - Checks authorization with `Health().hasPermissions([HealthDataType.WORKOUT])`.
  - Requests permissions via `Health().requestAuthorization(...)`.
  - Writes strength training sessions using `Health().writeWorkoutData(...)` with activity type `TRADITIONAL_STRENGTH_TRAINING`, start/end timestamps, energy burned in kcal, and exercise title.
- **Log Management**: Supports `updateWorkoutLog` and `deleteWorkoutLog` for full user control over past sessions.

---

### C. Body Map Widget (`presentation/widgets/body_map_widget.dart`)
- **Problem Solved**: Standard Flutter SVG cannot evaluate web CSS variables (`rgb(var(--bodymap-stroke))`) or web classes (`class="hidden"`), which originally caused SVG outlines to be invisible.
- **Dynamic Colorization**:
  - Outlines are transformed to `#334155` (deep slate).
  - Joint circles are hidden with `display="none"`.
  - The active target muscle group is dynamically highlighted with `#EF4444` (vibrant red).
  - Inactive resting muscles render with `#CBD5E1` (soft slate) for complete anatomical visibility.
- **Auto-Flip & Interactivity**:
  - Automatically switches between **Anterior (Front)** and **Posterior (Back)** depending on whether the selected target belongs to the posterior chain (e.g., hamstrings, glutes, lats, lower back, triceps).
  - Tapping the body map card directly flips between Front and Back views.
  - Selecting a muscle chip highlights the corresponding group without showing checkmark icons (`showCheckmark: false`).

---

### D. Exercise Detail & Video Dialog (`presentation/widgets/exercise_detail_dialog.dart`)
- **Video Player**:
  - Uses `video_player` with automatic loop playback (`controller.setLooping(true)`).
  - Default muted (`controller.setVolume(0.0)`) with a dedicated mute/unmute floating toggle button.
  - Fills container with `BoxFit.cover` inside a `FittedBox` for responsive video display.
  - Automatically defaults to the user's saved gender preference (`PrefKeys.gender`), with an instant toggle between male/female demonstrations.
- **Exercise Instructions & Cues**:
  - Displays equipment, target muscle, difficulty, step-by-step instructions, and form cues.
- **Add to Plan Sheet**:
  - Allows assigning the exercise to any day of the week with customized sets, reps, weight, and rest time.
- **Quick Log Bottom Sheet**:
  - Large touch-stepper cards for sets, reps, weight, duration, and estimated calories.
  - Includes a switch to sync directly to **Health Connect** or save locally.

---

### E. Break Timer (`presentation/widgets/break_timer_widget.dart`)
- Standalone rest timer widget with circular countdown progress.
- Presets: **30s**, **60s**, **90s**, and **120s**.
- Fine adjustments with **+15s** / **-15s** buttons.
- Vibration/haptic feedback on interval completion.

---

### F. Main Workout Screen (`presentation/screens/workout_screen.dart`)
Configured with a scrollable `TabBar` (`isScrollable: true, tabAlignment: TabAlignment.start`) divided into 3 tabs:

1. **Tab 1: Weekly Plan**
   - Day selector (Mon to Sun) with an indicator dot for today.
   - Quick statistics: Planned exercises, Logged today, Total calories burned.
   - Built-in `BreakTimerWidget` for rest between sets.
   - List of planned exercises:
     - **Tap card**: Opens `ExerciseDetailDialog` with looping video and full instructions.
     - **Green check button**: Directly logs the planned session.
     - **Trash button**: Displays a **Cupertino themed confirmation dialog** (`CupertinoAlertDialog`) before removing from the plan.
2. **Tab 2: Explore & Body Map**
   - Search bar filtering across names, target muscles, body parts, and aliases.
   - Modern pill difficulty filters (**All**, **Beginner**, **Intermediate**, **Advanced**) featuring colored accent dots and smooth transitions.
   - `BodyMapWidget` with anterior/posterior views for visual muscle targeting.
   - Exercise cards using `CachedNetworkImage` for smooth scrolling and caching.
3. **Tab 3: History & Health Connect**
   - List of all completed sessions showing sets, reps, weight, duration, and calories.
   - Visual badges indicating whether a workout was synced to **Health Connect** or saved **Locally**.
   - **Edit Action**: Opens a modal bottom sheet with touch steppers to adjust sets, reps, weight, duration, and calories.
   - **Delete Action**: Displays a **Cupertino themed confirmation dialog** (`CupertinoAlertDialog`) before permanently deleting the log.

---

## 4. Android Health Connect Native Setup

### Manifest Configuration (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Health Connect Permissions -->
<uses-permission android:name="android.permission.health.READ_EXERCISE"/>
<uses-permission android:name="android.permission.health.WRITE_EXERCISE"/>

<queries>
    <package android:name="com.google.android.apps.healthdata"/>
</queries>

<activity
    android:name=".MainActivity" ...>
    <!-- Health Connect Permissions rationale intent -->
    <intent-filter>
        <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE"/>
    </intent-filter>
</activity>
```

---

## 5. User Data Keys (`SharedPreferences`)

| Key | Purpose | Type |
|---|---|---|
| `workout_weekly_plan` | Stores weekly scheduled exercises (Mon-Sun) | JSON String |
| `workout_logs_history` | Stores completed workout session logs | JSON String |
| `PrefKeys.gender` | Auto-selects male or female video & thumbnail | String (`"male"` / `"female"`) |

---

## 6. How to Extend

1. **Adding New Exercises**:
   - Append to `assets/exercise.json` following the schema.
   - The loader in `WorkoutService.getExercises()` will automatically parse and display them.
2. **Adding Muscle Regions to Body Map**:
   - Add the target name mapping to `BodyMapWidget._targetToSvgId(...)`.
   - Ensure the group ID exists in `assets/front.svg` or `assets/back.svg`.
