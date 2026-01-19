# TestingTools

Swift package with UI testing utilities for iOS/macOS projects.

## Products

### ScreenshotKit (Library)

Capture screenshots in UI tests with structured naming.

- Automatic session timestamping
- Structured naming: `Run_{session}__Test_{name}__Step_{NN}__{timestamp}__{description}`
- XCTestCase extension for convenient usage
- Screenshots attached to xcresult for later extraction

### UITestKit (Library)

Common UI test utilities:

- **PageObject/** — `PageElement`, `ComponentElement` protocols, `BaseUITestSuite`
- **Extensions/** — `XCUIElement+WaitFor` for waiting on UI state changes
- **Allure/** — `AllureTrackable` protocol for Allure TestOps annotations

### extract-screenshots (CLI)

Extract screenshots from xcresult and organize into folders.

## Installation

### Add to Xcode Project

1. In Xcode: File → Add Package Dependencies
2. Enter the local path or repository URL
3. Add `ScreenshotKit` and `UITestKit` to your UI test target

### Package.swift

```swift
dependencies: [
    .package(path: "../TestingTools")
    // or: .package(url: "https://github.com/user/TestingTools", from: "1.0.0")
]
```

Add to your UI test target:

```swift
.testTarget(
    name: "YourAppUITests",
    dependencies: [
        .product(name: "ScreenshotKit", package: "TestingTools"),
        .product(name: "UITestKit", package: "TestingTools")
    ]
)
```

## Usage

### Basic UI Test with Screenshots

```swift
import XCTest
import ScreenshotKit
import UITestKit

final class MyUITests: BaseUITestSuite, AllureTrackable {

    override class func setUp() {
        super.setUp()
        ScreenshotManager.shared.startSession()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        startTestScreenshots()
    }

    @MainActor
    func testLogin() throws {
        let app = XCUIApplication()
        app.launch()
        screenshot(step: 1, "app_launched", app: app)

        app.textFields["username"].tap()
        app.textFields["username"].typeText("user@example.com")
        screenshot(step: 2, "username_entered", app: app)

        app.buttons["Login"].tap()
        screenshot(step: 3, "login_tapped", app: app)

        // Wait for UI state change instead of sleep
        XCTAssertTrue(app.staticTexts["Welcome"].waitFor(\.exists, toBe: true, timeout: 5))
        screenshot(step: 4, "login_successful", app: app)
    }
}
```

### Extract Screenshots

After running tests:

```bash
# Find latest xcresult
XCRESULT=$(ls -td ~/Library/Developer/Xcode/DerivedData/*/Logs/Test/*.xcresult | head -1)

# Extract to folder
swift run --package-path /path/to/TestingTools extract-screenshots "$XCRESULT" ./screenshots
```

Output structure:

```
screenshots/
  Run_2026-01-15_17-58-28/
    Test_testLogin/
      Step_01__17-58-31-280__app_launched.png
      Step_02__17-58-31-500__username_entered.png
      ...
```

## Project Structure

```
agents/skills/                     ← source of truth (visible in Finder)
  ios-ui-validation/               ← actual skill files
.claude/skills → ../agents/skills  ← symlink for Claude Code
.codex/skills → ../agents/skills   ← symlink for Codex CLI
```

**Pattern:** All skills live in `agents/skills/`. The `.claude/` and `.codex/` folders are just symlinks pointing to `agents/skills/`, so both Claude Code and Codex CLI automatically find the same skills. Edit skills in `agents/skills/` — changes are reflected everywhere via symlinks.

## AI Agent Skill

This package includes a skill for AI-assisted UI test development. Works with both **Claude Code** and **Codex CLI**.

### Setup Skill

```bash
# Project-local (copies skill + creates symlinks)
./Scripts/setup-project-skills.sh /path/to/your/project

# Or global (all projects)
./Scripts/setup-global-skills.sh
```

### What the Skill Provides

- **Page Object pattern** templates and examples
- **Accessibility ID naming** conventions (BEM-like)
- **Shared identifiers** setup between app and test targets
- **Allure integration** for test reporting
- **Screenshot workflow** with mandatory verification

### Skill Contents

- `assets/TestEnvShared/` — templates for shared test identifiers
- `assets/UIStruct/` — templates for Page Objects
- `references/` — detailed documentation

## Scripts

| Script | Description |
|--------|-------------|
| `check-tools.sh` | Verify required tools are installed |
| `setup-global-skills.sh` | Install skill globally (~/) |
| `setup-project-skills.sh` | Install skill to a project |
| `run-tests-and-extract.sh` | Run UI tests + extract screenshots |
| `extract-screenshots.sh` | Extract screenshots from xcresult |

### Examples

```bash
# Check tools before starting
./Scripts/check-tools.sh

# Run tests and extract screenshots in one command
./Scripts/run-tests-and-extract.sh -workspace App.xcworkspace -scheme App

# Install skill to your project
./Scripts/setup-project-skills.sh /path/to/your/project
```

## Requirements

- iOS 15.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

Run `./Scripts/check-tools.sh` to verify.
