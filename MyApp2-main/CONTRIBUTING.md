# Contributing to Tax Buddy

Thanks for your interest in improving Tax Buddy. This app is built to help first-time filers, especially teens, learn taxes in a calmer and more approachable way. Contributions should keep that mission in mind.

## Ways to Contribute

- Report bugs or confusing steps.
- Suggest clearer wording for beginners.
- Improve SwiftUI layout, spacing, and accessibility.
- Add or improve practice-mode examples.
- Help test the app on different iPhone sizes.
- Refactor code to make the app easier to maintain.

## Reporting Issues

When opening an issue, please include:

- A short title that explains the problem.
- Whether it happens in Practice Mode, Real Mode, or both.
- The step number, if the issue happens during the tax walkthrough.
- What you expected to happen.
- What actually happened.
- Screenshots or screen recordings, if helpful.
- Your Xcode version and simulator/device, if it is a build or UI issue.

For tax-related wording issues, please explain what part feels confusing or too advanced for a beginner.

## Before You Start Coding

1. Fork the repository.
2. Create a new branch from `main`.
3. Keep your change focused on one feature, bug fix, or cleanup.
4. Avoid committing secrets, personal tax information, or real user data.

Example branch names:

```bash
feature/practice-step-copy
fix/step-12-spacing
docs/update-readme
```

## Development Setup

Open the Xcode project:

```bash
open Tax_Buddy/Tax_Buddy.xcodeproj
```

Or build from the command line:

```bash
xcodebuild -project Tax_Buddy/Tax_Buddy.xcodeproj -scheme Tax_Buddy -sdk iphonesimulator build
```

## Pull Request Guidelines

Before submitting a pull request:

- Make sure the app builds successfully.
- Test the flow you changed in the iPhone simulator.
- Keep text simple and beginner-friendly.
- Preserve the difference between Practice Mode and Real Mode unless your change intentionally affects both.
- Do not remove or rename assets without updating the related step logic.
- Do not add credentials, API keys, or personal information.

In your pull request description, include:

- What changed.
- Why the change was made.
- How you tested it.
- Screenshots for UI changes, if possible.

## Code Style

- Follow the existing SwiftUI style in the project.
- Prefer small, readable changes over large rewrites.
- Use clear names for views, state values, and helper methods.
- Keep the app friendly for first-time filers.
- Add comments only when they make complex code easier to understand.

## Tax and Safety Notes

Tax Buddy is an educational tool, not professional tax advice. Please avoid adding language that makes the app sound like a replacement for a CPA, tax attorney, or official IRS guidance.

Practice data must always be fake. Never add real names, real SSNs, real bank information, or real tax documents.

## Good First Issues

Good starter contributions include:

- Simplifying wording in a single step.
- Improving spacing on one screen.
- Adding accessibility labels.
- Fixing a typo.
- Updating documentation.

Thanks for helping make tax learning less intimidating.
