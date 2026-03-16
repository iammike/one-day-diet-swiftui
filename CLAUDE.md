# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

One Day Diet is an iOS SwiftUI app for tracking daily food intake against a scoring system from "Racing Weight" by Matt Fitzgerald. Users track servings across 10 food groups (scored positive/negative) plus optional macro tracking.

## Building & Running

This is a standard Xcode project with no build scripts or package managers.

- Open `One Day Diet.xcodeproj` in Xcode
- Build: `Cmd+B`
- Run: `Cmd+R`
- Run tests: `Cmd+U`

From command line:
```bash
xcodebuild -project "One Day Diet.xcodeproj" -scheme "One Day Diet" -destination "generic/platform=iOS Simulator" build
xcodebuild -project "One Day Diet.xcodeproj" -scheme "One Day Diet" -destination "generic/platform=iOS Simulator" test
```

## Architecture

**Pattern**: MVVM with SwiftUI

- `ContentView.swift` - Main UI and `@main` app entry point
- `ViewModel.swift` - All state management and UserDefaults persistence
- `FoodGroupsData.swift` - `FoodGroup` struct and 10 food group definitions with score arrays
- `TrackablesData.swift` - `Trackable` struct and macro definitions (Water, Carbs, Protein, Fat)
- `FoodGroupStepperView.swift` / `TrackableStepperView.swift` - Reusable stepper components
- `WhatsNewAlert.swift` - Version-based "What's New" alert logic

## Key Data Flow

1. `ViewModel` owns all state as `@Published` properties
2. `ContentView` holds a `@StateObject` reference to ViewModel
3. On app launch, ViewModel reads from UserDefaults and resets servings if the date has changed
4. Score is calculated by indexing into each `FoodGroup.scores` array at the current serving count

## Storage

UserDefaults only (no CoreData, no network). The `UserDefaultsKeys` struct in `ViewModel.swift` holds most keys; `showMacrosKey` is defined in an extension in `ContentView.swift`, and `WhatsNewAlert` uses the string literal `"lastVersionPromptedForReview"` directly. Persisted data:
- Daily servings per food group (keyed by date string `yyyy-MM-dd`)
- Last accessed date (for auto-reset at midnight)
- Macro tracking opt-in preference
- Last prompted app version (for What's New alerts)

## Scoring System

Each `FoodGroup` has a `scores: [Int]` array where the index equals the number of servings. Scoring is positive for healthy groups (Fruits, Vegetables, etc.) and negative for unhealthy groups (Refined Grains, Sweets, etc.). Daily total score sums contributions from all 10 groups.
