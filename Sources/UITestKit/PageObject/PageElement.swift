import XCTest

/// Protocol for Page Objects in UI tests
@MainActor
public protocol PageElement {
    func waitForAppear()
}

/// Protocol for Component Objects in UI tests
@MainActor
public protocol ComponentElement {
    func waitForAppear()
}
