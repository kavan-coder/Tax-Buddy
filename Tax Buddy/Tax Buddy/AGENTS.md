# Tax Buddy Agent Guide

## Purpose
- `Tax_Buddy` is an iOS SwiftUI app for helping first-time filers learn the federal tax filing flow.
- The app has two paths:
  - `practice` mode uses sample data and bundled example documents.
  - `real` mode guides the user through the same steps with their own numbers.
- Tax estimation is currently generated from a bundled PDF tax reference using `FirebaseAI`.

## Project Layout
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/Tax_BuddyApp.swift`
  - App entry point.
  - Configures Firebase in `AppDelegate`.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/Opening.swift`
  - Splash/opening experience.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/Welcome.swift`
  - Main landing screen with navigation into practice or real filing flows.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/StepsView.swift`
  - Core guided tax workflow.
  - Defines the step data model and both mode-specific filing steps.
  - Loads the bundled PDF reference and calls the Gemini model through `FirebaseAI`.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/tax analysis.pdf`
  - Bundled tax reference used to derive the estimated tax value.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/Assets.xcassets`
  - Sample images and app assets.
- `/Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy/GoogleService-Info.plist`
  - Firebase configuration. Treat as sensitive project config.

## Stack
- SwiftUI app target inside `Tax_Buddy.xcodeproj`
- Swift 5
- Firebase Core
- Firebase AI / Google AI backend
- PDFKit

## Build Notes
- Open the project in Xcode:
  - `open /Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy.xcodeproj`
- Typical CLI build command:
  - `xcodebuild -project /Users/kavan_desai/Desktop/Tax_Buddy/Tax_Buddy.xcodeproj -scheme Tax_Buddy -sdk iphonesimulator build`
- There is no dedicated test target in the repo right now. Prefer adding tests before large logic changes.

## Agent Working Rules
- Preserve the current SwiftUI-first architecture unless a refactor is clearly necessary.
- Keep practice-mode and real-mode behavior aligned unless the product explicitly needs them to diverge.
- Be careful with `StepsView.swift`: it currently mixes UI, workflow state, PDF parsing, and AI calls in one file, so small edits can have broad effects.
- When changing tax-calculation behavior, verify whether the change affects both:
  - Prompt construction for `FirebaseAI`
  - Display logic for Step 9 and later steps
- Avoid hardcoding secrets or adding new credentials to the repo.
- Do not remove or rename bundled assets or the PDF file without updating the app flow accordingly.

## Good Next Refactors
- Extract tax calculation logic from `StepsView` into a separate service.
- Extract practice and real filing steps into dedicated data sources.
- Add unit tests for number extraction and tax-step progression.
- Add validation for user-entered taxable income before triggering AI calculation.

## Product Context
- The UI is intentionally friendly and beginner-oriented.
- Clear language matters more than technical tax jargon.
- Changes should prioritize approachability for first-time filers.
