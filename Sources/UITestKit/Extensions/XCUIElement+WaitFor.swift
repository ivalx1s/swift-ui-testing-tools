import XCTest

public extension XCUIElement {
    /// Wait for a specific property of the element to reach an expected value.
    /// - Parameters:
    ///   - keyPath: KeyPath to the property to observe
    ///   - expectedValue: The value to wait for
    ///   - timeout: Maximum time to wait in seconds
    ///   - pollingInterval: Interval between checks in seconds
    /// - Returns: true if the property reached the expected value within timeout
    func waitFor<T: Equatable>(
        _ keyPath: KeyPath<XCUIElement, T>,
        toBe expectedValue: T,
        timeout: TimeInterval,
        pollingInterval: TimeInterval = 0.1
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if self[keyPath: keyPath] == expectedValue {
                return true
            }
            Thread.sleep(forTimeInterval: pollingInterval)
        }
        return self[keyPath: keyPath] == expectedValue
    }

    /// Convenience property to get value as String
    var stringValue: String {
        (value as? String) ?? ""
    }
}
