import XCTest
@testable import Device

final class DeviceTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Device().text, "Hello, World!")
    }
}
