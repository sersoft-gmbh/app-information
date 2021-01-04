import XCTest
@testable import AppInformation
#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
#endif

final class AppInfoTests: XCTestCase {
    private final class FakeBundle: Bundle {
        var _identifier: String?
        override var bundleIdentifier: String? { _identifier }

        var _infoDict: Dictionary<String, Any>?
        override var infoDictionary: [String : Any]? { _infoDict }

        var _localizedInfoDict: Dictionary<String, Any>?
        override var localizedInfoDictionary: [String : Any]? { _localizedInfoDict }

        init(path: String,
             identifier: String? = nil,
             infoDict: Dictionary<String, Any>? = nil,
             localizedInfoDict: Dictionary<String, Any>? = nil) {
            _identifier = identifier
            _infoDict = infoDict
            _localizedInfoDict = localizedInfoDict
            super.init(path: path)!
        }
    }

    private var bundlePath: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        bundlePath = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathExtension("bundle")
            .path
        try FileManager.default.createDirectory(atPath: bundlePath, withIntermediateDirectories: true, attributes: nil)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: bundlePath)
        bundlePath = nil
        try super.tearDownWithError()
    }

    func testCreationFromEmptyBundle() {
        let info = AppInfo(bundle: FakeBundle(path: bundlePath))

        XCTAssertEqual(info.identifier, String(ProcessInfo.processInfo.processIdentifier))
        XCTAssertEqual(info.names.unlocalized.base, ProcessInfo.processInfo.processName)
        XCTAssertNil(info.names.unlocalized.display)
        XCTAssertNil(info.names.localized.base)
        XCTAssertNil(info.names.localized.display)
        XCTAssertEqual(info.versioning.version, "1.0.0")
        XCTAssertEqual(info.versioning.build, "1")
        XCTAssertNil(info.copyright)
        XCTAssertNil(info.appleID)
    }

    func testCreationFromEmptyBundleAndAppleID() {
        let info = AppInfo(bundle: FakeBundle(path: bundlePath), appleID: "12345")

        XCTAssertEqual(info.identifier, String(ProcessInfo.processInfo.processIdentifier))
        XCTAssertEqual(info.names.unlocalized.base, ProcessInfo.processInfo.processName)
        XCTAssertNil(info.names.unlocalized.display)
        XCTAssertNil(info.names.localized.base)
        XCTAssertNil(info.names.localized.display)
        XCTAssertEqual(info.versioning.version, "1.0.0")
        XCTAssertEqual(info.versioning.build, "1")
        XCTAssertNil(info.copyright)
        XCTAssertEqual(info.appleID, "12345")
    }

    func testCreationFromUnlocalizedBundle() {
        let bundle = FakeBundle(path: bundlePath,
                                identifier: "test-identifier",
                                infoDict: [
                                    "CFBundleShortVersionString": "1.2.3",
                                    "CFBundleVersion": "42",
                                    "CFBundleName": "TestName",
                                    "CFBundleDisplayName": "Test Display Name",
                                    "NSHumanReadableCopyright": "Some Copyright",
                                    "AppInformationAppleID": "54321",
                                ])
        let info = AppInfo(bundle: bundle)

        XCTAssertEqual(info.identifier, "test-identifier")
        XCTAssertEqual(info.names.unlocalized.base, "TestName")
        XCTAssertEqual(info.names.unlocalized.display, "Test Display Name")
        XCTAssertNil(info.names.localized.base)
        XCTAssertNil(info.names.localized.display)
        XCTAssertEqual(info.versioning.version, "1.2.3")
        XCTAssertEqual(info.versioning.build, "42")
        XCTAssertEqual(info.copyright, "Some Copyright")
        XCTAssertEqual(info.appleID, "54321")
    }

    func testCreationFromLocalizedBundle() {
        let bundle = FakeBundle(path: bundlePath,
                                identifier: "test-identifier",
                                infoDict: [
                                    "CFBundleShortVersionString": "1.2.3",
                                    "CFBundleVersion": "42",
                                    "CFBundleName": "TestName",
                                    "CFBundleDisplayName": "Test Display Name",
                                    "NSHumanReadableCopyright": "Some Copyright",
                                    "AppInformationAppleID": "54321",
                                ],
                                localizedInfoDict: [
                                    "CFBundleShortVersionString": "irrelevant",
                                    "CFBundleVersion": "more-irrelevant",
                                    "CFBundleName": "LocalizedTestName",
                                    "CFBundleDisplayName": "Localized Test Display Name",
                                    "NSHumanReadableCopyright": "Some Localized Copyright",
                                    "AppInformationAppleID": "most-irrelevant",
                                ])
        let info = AppInfo(bundle: bundle)

        XCTAssertEqual(info.identifier, "test-identifier")
        XCTAssertEqual(info.names.unlocalized.base, "TestName")
        XCTAssertEqual(info.names.unlocalized.display, "Test Display Name")
        XCTAssertEqual(info.names.localized.base, "LocalizedTestName")
        XCTAssertEqual(info.names.localized.display, "Localized Test Display Name")
        XCTAssertEqual(info.versioning.version, "1.2.3")
        XCTAssertEqual(info.versioning.build, "42")
        XCTAssertEqual(info.copyright, "Some Localized Copyright")
        XCTAssertEqual(info.appleID, "54321")
    }

    func testIdentifiableConformance() {
        let info = AppInfo(bundle: FakeBundle(path: bundlePath))
        XCTAssertEqual(info.id, info.identifier)
    }

    func testNamingAccessors() {
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "relevant", display: nil),
                                              localized: (nil, nil)).effectiveName,
                       "relevant")
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "relevant"),
                                              localized: (nil, nil)).effectiveName,
                       "relevant")
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"),
                                              localized: ("relevant", nil)).effectiveName,
                       "relevant")
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"),
                                              localized: ("not-relevant", "relevant")).effectiveName,
                       "relevant")
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "relevant", display: nil),
                                              localized: (nil, nil)).effective,
                       ("relevant", nil))
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "relevant", display: "also-relevant"),
                                              localized: (nil, nil)).effective,
                       ("relevant", "also-relevant"))
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "relevant", display: "not-relevant"),
                                              localized: (nil, "also-relevant")).effective,
                       ("relevant", "also-relevant"))
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "also-relevant"),
                                              localized: ("relevant", nil)).effective,
                       ("relevant", "also-relevant"))
        XCTAssertEqual(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"),
                                              localized: ("relevant", "also-relevant")).effective,
                       ("relevant", "also-relevant"))
    }

    func testNamingEquatableConformance() {
        let naming1 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: (nil, nil))
        let naming2 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: ("loc-base", nil))
        let naming3 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: (nil, nil))
        XCTAssertEqual(naming1, naming3)
        XCTAssertNotEqual(naming1, naming2)
        XCTAssertNotEqual(naming2, naming3)
    }

    func testVersioningAccessors() {
        let versioning = AppInfo.Versioning(version: "1.2.3", build: "42")
        XCTAssertEqual(versioning.combined, "1.2.3 (42)")
    }

    func testSwiftUIEnvironment() throws {
        #if canImport(SwiftUI) && canImport(Combine)
        let info = AppInfo(bundle: FakeBundle(path: bundlePath))
        var env = EnvironmentValues()
        XCTAssertEqual(env.appInfo, .current)
        env.appInfo = info
        XCTAssertEqual(env.appInfo, info)
        #else
        throw XCTSkip()
        #endif
    }
}

fileprivate func XCTAssertEqual<T1: Equatable, T2: Equatable>(_ lhs: @autoclosure () throws -> (T1, T2),
                                                              _ rhs: @autoclosure () throws -> (T1, T2),
                                                              _ message: @autoclosure () -> String = "",
                                                              file: StaticString = #file,
                                                              line: UInt = #line) {
    XCTAssert(try lhs() == rhs(), message(), file: file, line: line)
}

