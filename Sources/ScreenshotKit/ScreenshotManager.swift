//
//  ScreenshotManager.swift
//  ScreenshotKit
//
//  Manages screenshots with structured naming for easy extraction from xcresult.
//

import XCTest

/// Manages screenshots with structured naming for easy extraction from xcresult.
///
/// Naming format: `Run_{session}__Test_{name}__Step_{NN}__{timestamp}__{description}`
///
/// Example: `Run_2026-01-15_17-58-28__Test_testLogin__Step_01__17-58-31-280__app_launched`
@MainActor
public final class ScreenshotManager {
    public static let shared = ScreenshotManager()

    private var sessionTimestamp: String = ""
    private var currentTestName: String = ""

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return df
    }()

    private let stepTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH-mm-ss-SSS"
        return df
    }()

    private init() {}

    /// Call once at the start of test suite (typically in `override class func setUp()`)
    public func startSession() {
        sessionTimestamp = dateFormatter.string(from: Date())
        print("📸 Test session: \(sessionTimestamp)")
    }

    /// Call at the start of each test (typically in `override func setUpWithError()`)
    public func startTest(named testName: String) {
        if sessionTimestamp.isEmpty {
            startSession()
        }
        // Clean up test name: "-[Class testMethod]" -> "testMethod"
        currentTestName = testName
            .replacingOccurrences(of: "-[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .components(separatedBy: " ").last ?? testName
    }

    /// Take screenshot and attach to test with structured name.
    ///
    /// - Parameters:
    ///   - step: Step number (1-based)
    ///   - description: Short description of what's being captured (use snake_case)
    ///   - app: The XCUIApplication instance
    ///   - testCase: The XCTestCase instance (pass `self`)
    public func capture(step: Int, _ description: String, app: XCUIApplication, testCase: XCTestCase) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        let stepTimestamp = stepTimeFormatter.string(from: Date())

        // Format: Run_{session}__Test_{name}__Step_{NN}__{timestamp}__{description}
        attachment.name = String(
            format: "Run_%@__Test_%@__Step_%02d__%@__%@",
            sessionTimestamp,
            currentTestName,
            step,
            stepTimestamp,
            description
        )
        attachment.lifetime = .keepAlways
        testCase.add(attachment)

        print("📸 \(currentTestName) Step \(step) [\(stepTimestamp)]: \(description)")
    }
}
