//
//  XCTestCase+Screenshot.swift
//  ScreenshotKit
//
//  Convenience extension for XCTestCase to capture screenshots.
//

import XCTest

public extension XCTestCase {
    /// Take a screenshot with structured naming.
    ///
    /// - Parameters:
    ///   - step: Step number (1-based)
    ///   - description: Short description (use snake_case)
    ///   - app: The XCUIApplication instance
    @MainActor
    func screenshot(step: Int, _ description: String, app: XCUIApplication) {
        ScreenshotManager.shared.capture(step: step, description, app: app, testCase: self)
    }

    /// Call at the start of each test to register the test name.
    @MainActor
    func startTestScreenshots() {
        ScreenshotManager.shared.startTest(named: self.name)
    }
}
