import Foundation
import Testing
@testable import AppInformation

@Suite
struct AppInfoAppleIDTests {
    @Test
    func creation() {
        let appleID = AppInfo.AppleID(rawValue: "test-creation")
        #expect(appleID.rawValue == "test-creation")
    }

    @Test
    func creationFromStringLiteral() {
        let appleID: AppInfo.AppleID = "test"
        #expect(appleID.rawValue == "test")
    }

    @Test
    func urlAccessors() {
        let appleID = AppInfo.AppleID("12345")
        #expect(appleID.appStoreURL == URL(string: "https://apps.apple.com/app/id12345"))
        #expect(appleID.reviewURL == URL(string: "https://apps.apple.com/app/id12345?action=write-review"))
    }
}
