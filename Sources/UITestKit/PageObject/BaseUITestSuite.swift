import XCTest

/// Base test class with common setup for UI tests
open class BaseUITestSuite: XCTestCase {
    override open func setUp() {
        super.setUp()
        continueAfterFailure = false

        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            Task { @MainActor in
                if alert.buttons["Allow"].exists { alert.buttons["Allow"].tap() }
                if alert.buttons["Don't Allow"].exists { alert.buttons["Don't Allow"].tap() }
                if alert.buttons["OK"].exists { alert.buttons["OK"].tap() }
            }
            return true
        }
    }
}
