# Learning Journey

An iOS app that helps you build a daily learning habit. Set a goal and a duration, log each day as **Learned** or **Freezed**, and keep your streak alive.


## Features

- **Set a goal:** Choose what to learn and for how long (Week, Month, or Year).
- **Track your days:** Log today as Learned, or use a Freeze to protect your streak.
- **Follow your progress:** A weekly strip and a full calendar show every logged day.
- **Update your goal:** Change the goal or duration at any time (the streak restarts).
- **Goal results:** See a Goal Completed or Goal not met screen when your goal ends.

## How It Works

- **Streak:** Increases with every Learned day. It breaks if more than 32 hours pass without logging a Learned day or using a Freeze, or when the goal is updated.
- **Freezes:** Limited by duration: 2 for a week, 8 for a month, 96 for a year.
- **Daily logging:** One log per day. You can switch between Learned and Freeze on the same day. Buttons reset at 12 AM.
- **Goal result:** Completed if you stay committed to every day. Not met as soon as the streak breaks.

## Requirements

- Xcode with the iOS 27 SDK or later
- A simulator or device running iOS 27+

## Getting Started

1. Open `LearningApp.xcodeproj` in Xcode.
2. Choose an iOS 26+ simulator or device.
3. Press Run (⌘R).

The first launch opens Onboarding. After that, the app opens directly on Activity. To start over, delete the app from the simulator or device.

## Project Structure

Built with SwiftUI and MVVM.

```
LearningApp
├── Models
│   ├── Duration.swift              Duration options and Freeze limits
│   └── LearningLog.swift           Logged days and persistence (single shared source)
├── ViewModels
│   ├── OnboardingViewModel.swift
│   ├── ActivityViewModel.swift     Streak, Freeze, and goal state rules
│   ├── UpdateGoalViewModel.swift
│   └── CalendarViewModel.swift
├── Views
│   ├── AppRoot.swift               Navigation between screens
│   ├── OnboardingView.swift
│   ├── ActivityView.swift
│   ├── UpdateGoalView.swift
│   ├── CalendarView.swift
│   └── GlassStyle.swift            App colors and glass button style
└── LearningAppApp.swift
```

The weekly strip and the calendar both read from the same `LearningLog`, so a logged day appears in both automatically. Data is stored in `UserDefaults`.

## Testing Goal End States

Goal end states normally take a long time to reach, so `ActivityView.swift` includes Xcode Previews for them:

1. Open `ActivityView.swift` and enable the Canvas (⌥⌘↩).
2. Select **Active**, **Goal completed**, or **Goal not met** at the bottom of the Canvas.

The Previews write to `UserDefaults`, so delete the app from the simulator before testing the real flow.

## Author

Wafa Saif
