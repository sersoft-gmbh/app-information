import XCTest
@testable import AppInformation
#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
#endif

final class ApplicationAppleIDTests: XCTestCase {
    func testCreation() {
        let appleID = ApplicationAppleID(rawValue: "test-creation")
        XCTAssertEqual(appleID.rawValue, "test-creation")
    }

    func testCreationFromStringLiteral() {
        let appleID: ApplicationAppleID = "test"
        XCTAssertEqual(appleID.rawValue, "test")
    }

    func testURLAccessors() {
        let appleID = ApplicationAppleID("12345")
        XCTAssertEqual(appleID.appStoreURL, URL(string: "https://apps.apple.com/app/id12345"))
        XCTAssertEqual(appleID.reviewURL, URL(string: "https://apps.apple.com/app/id12345?action=write-review"))
    }

    func testSwiftUIEnvironment() throws {
        #if canImport(SwiftUI) && canImport(Combine)
        let appleID = ApplicationAppleID("54321")
        var env = EnvironmentValues()
        XCTAssertNil(env.applicationAppleID)
        env.applicationAppleID = appleID
        XCTAssertEqual(env.applicationAppleID, appleID)
        #else
        throw XCTSkip()
        #endif
    }
}
