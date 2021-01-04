import XCTest
@testable import AppInformation
#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
#endif

final class AppInfo_AppleIDTests: XCTestCase {
    func testCreation() {
        let appleID = AppInfo.AppleID(rawValue: "test-creation")
        XCTAssertEqual(appleID.rawValue, "test-creation")
    }

    func testCreationFromStringLiteral() {
        let appleID: AppInfo.AppleID = "test"
        XCTAssertEqual(appleID.rawValue, "test")
    }

    func testURLAccessors() {
        let appleID = AppInfo.AppleID("12345")
        XCTAssertEqual(appleID.appStoreURL, URL(string: "https://apps.apple.com/app/id12345"))
        XCTAssertEqual(appleID.reviewURL, URL(string: "https://apps.apple.com/app/id12345?action=write-review"))
    }
}
