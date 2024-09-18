import XCTest
@testable import AppInformation
#if arch(arm64) || arch(x86_64)
#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
#endif
#endif

final class AppInfoTests: XCTestCase {
    private var bundleURL: URL!
    private var bundlePath: String { bundleURL.path }

    private func tempDir() -> URL {
        if #available(iOS 10, tvOS 10, watchOS 3.0, *) {
            return FileManager.default.temporaryDirectory
        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

    private func fillBundle(identifier: String? = nil,
                            infoDict: Dictionary<String, Any>? = nil,
                            localizedInfoDict: Dictionary<String, Any>? = nil) throws {
        var infoDict = infoDict ?? [:]
        if let identifier {
            infoDict["CFBundleIdentifier"] = identifier
        }
        let contentsURL = bundleURL.appendingPathComponent("Contents", isDirectory: true)
        let infoPlistURL = contentsURL.appendingPathComponent("Info.plist", isDirectory: false)
        let data = try PropertyListSerialization.data(fromPropertyList: infoDict, format: .xml, options: 0)
        try data.write(to: infoPlistURL, options: .atomic)
        if let localizedInfoDict {
            let locale = Locale.current.identifier
            let lprojFolderURL = contentsURL
                .appendingPathComponent("Resources", isDirectory: true)
                .appendingPathComponent("\(locale).lproj", isDirectory: true)
            try FileManager.default.createDirectory(at: lprojFolderURL, withIntermediateDirectories: true)
            let stringsFile = lprojFolderURL.appendingPathComponent("InfoPlist.strings", isDirectory: false)
            try localizedInfoDict
                .lazy
                .map { #""\#($0.key)" = "\#($0.value)";"# }
                .joined(separator: "\n")
                .write(to: stringsFile, atomically: true, encoding: .utf16)
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        bundleURL = tempDir()
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathExtension("bundle")
        let contentsDir = bundleURL.appendingPathComponent("Contents", isDirectory: true)
        try FileManager.default.createDirectory(at: contentsDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: bundleURL)
        bundleURL = nil
        try super.tearDownWithError()
    }

    func testCreationFromEmptyBundle() throws {
        try fillBundle()
        let info = try AppInfo(bundle: XCTUnwrap(Bundle(path: bundlePath)))

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

    func testCreationFromEmptyBundleAndAppleID() throws {
        try fillBundle()
        let info = try AppInfo(bundle: XCTUnwrap(Bundle(path: bundlePath)), appleID: "12345")

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

    func testCreationFromUnlocalizedBundle() throws {
        try fillBundle(identifier: "test-identifier",
                       infoDict: [
                        "CFBundleShortVersionString": "1.2.3",
                        "CFBundleVersion": "42",
                        "CFBundleName": "TestName",
                        "CFBundleDisplayName": "Test Display Name",
                        "NSHumanReadableCopyright": "Some Copyright",
                        "AppInformationAppleID": "54321",
                       ])
        let bundle = try XCTUnwrap(Bundle(path: bundlePath))
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

    func testCreationFromLocalizedBundle() throws {
        try fillBundle(identifier: "test-identifier",
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
        let bundle = try XCTUnwrap(Bundle(path: bundlePath))
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

    func testIdentifiableConformance() throws {
        try fillBundle()
        let info = try AppInfo(bundle: XCTUnwrap(Bundle(path: bundlePath)))
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
#if arch(arm64) || arch(x86_64)
#if canImport(SwiftUI) && canImport(Combine)
        guard #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
        else { throw XCTSkip() }
        let info = try AppInfo(bundle: XCTUnwrap(Bundle(path: bundlePath)))
        var env = EnvironmentValues()
        XCTAssertEqual(env.appInfo, .current)
        env.appInfo = info
        XCTAssertEqual(env.appInfo, info)
#else
        throw XCTSkip()
#endif
#else
        throw XCTSkip()
#endif
    }
}

fileprivate func XCTAssertEqual<T1: Equatable, T2: Equatable>(_ lhs: @autoclosure () throws -> (T1, T2),
                                                              _ rhs: @autoclosure () throws -> (T1, T2),
                                                              _ message: @autoclosure () -> String = "",
                                                              file: StaticString = #filePath,
                                                              line: UInt = #line) {
    XCTAssert(try lhs() == rhs(), message(), file: file, line: line)
}

