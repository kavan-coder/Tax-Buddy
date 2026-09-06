# Tax Buddy

Tax Buddy is a SwiftUI iOS app that helps first-time filers learn the basics of filing a federal tax return. It is designed to feel approachable for teens and beginners by breaking the Form 1040 flow into small guided steps.

## What It Does

- **Practice Mode** gives users fake sample filer data, example documents, and step-by-step lessons so they can learn without using real personal information.
- **Real Mode** guides users through the same filing flow with their own numbers and simpler explanations.
- **Tax Estimation** uses a bundled tax reference PDF and Firebase AI to estimate tax owed from the user's taxable income.
- **Beginner-Friendly UI** focuses on clear instructions, visual cards, and simple language instead of tax jargon.

## Main Features

- Guided Form 1040 walkthrough
- Fake practice profiles for safe learning
- Practice and real filing paths
- Estimated tax calculation
- Overpayment vs. amount-owed routing
- Example form images and visual step cards
- Friendly welcome screen for choosing a learning path

## Tech Stack

- Swift 5
- SwiftUI
- Firebase Core
- Firebase AI / Google AI backend
- PDFKit
- Xcode iOS project

## Project Structure

```text
Tax_Buddy/
├── Tax_Buddy/
│   ├── Tax_BuddyApp.swift       # App entry point and Firebase setup
│   ├── Opening.swift            # Opening/splash experience
│   ├── Welcome.swift            # Main landing screen
│   ├── StepsView.swift          # Guided tax workflow
│   ├── tax analysis.pdf         # Bundled tax reference
│   ├── GoogleService-Info.plist # Firebase project config
│   └── Assets.xcassets/         # Images and app assets
└── Tax_Buddy.xcodeproj
```

## Getting Started

1. Clone the repository.

```bash
git clone https://github.com/MintyCoder2640/MyApp2.git
```

2. Open the Xcode project.

```bash
open Tax_Buddy/Tax_Buddy.xcodeproj
```

3. Select an iPhone simulator or connected iPhone.

4. Build and run the app in Xcode.

## Command-Line Build

```bash
xcodebuild -project Tax_Buddy/Tax_Buddy.xcodeproj -scheme Tax_Buddy -sdk iphonesimulator build
```

## Important Note

Tax Buddy is an educational tool. Any tax amount shown by the app should be treated as an estimate, not professional tax advice. Users should consult a CPA, tax attorney, or trusted tax professional when filing real taxes.

## Future Improvements

- Separate tax calculation logic from the main SwiftUI view
- Add unit tests for tax calculations and step routing
- Improve validation for user-entered numbers
- Add more beginner lessons for each document type
- Expand practice scenarios for different filing outcomes
