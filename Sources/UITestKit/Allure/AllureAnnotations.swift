import XCTest

/// Protocol for Allure test tracking annotations
@MainActor
public protocol AllureTrackable {
    func epic(_ values: String...)
    func story(_ values: String...)
    func suite(_ values: String...)
    func owner(_ values: String...)
    func testCase(allureId: String, label: String)
    func step(_ name: String, action: () -> Void)
}

public extension AllureTrackable {
    func epic(_ values: String...) {
        setLabels(name: "feature", values: values)
    }

    func story(_ values: String...) {
        setLabels(name: "story", values: values)
    }

    func suite(_ values: String...) {
        setLabels(name: "suite", values: values)
    }

    func owner(_ values: String...) {
        setLabels(name: "owner", values: values)
    }

    func testCase(allureId: String, label: String) {
        setNames(name: "name", values: [label])
        setAllureId(allureId)
    }

    func step(_ name: String, action: () -> Void) {
        XCTContext.runActivity(named: name) { _ in
            action()
        }
    }

    private func setAllureId(_ values: String...) {
        setLabels(name: "AS_ID", values: values)
    }

    private func setLabels(name: String, values: [String]) {
        for value in values {
            XCTContext.runActivity(named: "allure.label.\(name):\(value)") { _ in }
        }
    }

    private func setNames(name: String, values: [String]) {
        for value in values {
            XCTContext.runActivity(named: "allure.\(name):\(value)") { _ in }
        }
    }
}
