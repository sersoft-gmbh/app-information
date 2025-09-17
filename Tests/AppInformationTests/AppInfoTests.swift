import Foundation
import Testing
@testable import AppInformation
#if canImport(SwiftUI)
import SwiftUI
#endif

@Suite
struct AppInfoTests: ~Copyable {
    private let bundleURL: URL
    private var bundlePath: String { bundleURL.path }

    init() throws {
        let tempDir = if #available(iOS 10, tvOS 10, watchOS 3.0, *) {
            FileManager.default.temporaryDirectory
        } else {
            URL(fileURLWithPath: NSTemporaryDirectory())
        }
        bundleURL = tempDir
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathExtension("bundle")
        let contentsDir = bundleURL.appendingPathComponent("Contents", isDirectory: true)
        try FileManager.default.createDirectory(at: contentsDir, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: bundleURL)
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
            let lprojName: String
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                lprojName = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
            } else {
                lprojName = Locale.current.languageCode ?? Locale.current.identifier
            }
            let lprojFolderURL = contentsURL
                .appendingPathComponent("Resources", isDirectory: true)
                .appendingPathComponent("\(lprojName).lproj", isDirectory: true)
            try FileManager.default.createDirectory(at: lprojFolderURL, withIntermediateDirectories: true)
            let stringsFile = lprojFolderURL.appendingPathComponent("InfoPlist.strings", isDirectory: false)
            try localizedInfoDict
                .lazy
                .map { #""\#($0.key)" = "\#($0.value)";"# }
                .joined(separator: "\n")
                .write(to: stringsFile, atomically: true, encoding: .utf8)
        }
    }

    @Test
    func creationFromEmptyBundle() throws {
        try fillBundle()
        let info = try AppInfo(bundle: #require(Bundle(path: bundlePath)))

        #expect(info.identifier == String(ProcessInfo.processInfo.processIdentifier))
        #expect(info.names.unlocalized.base == ProcessInfo.processInfo.processName)
        #expect(info.names.unlocalized.display == nil)
        #expect(info.names.localized.base == nil)
        #expect(info.names.localized.display == nil)
        #expect(info.versioning.version == "1.0.0")
        #expect(info.versioning.build == "1")
        #expect(info.copyright == nil)
        #expect(info.appleID == nil)
    }

    @Test
    func creationFromEmptyBundleAndAppleID() throws {
        try fillBundle()
        let info = try AppInfo(bundle: #require(Bundle(path: bundlePath)), appleID: "12345")

        #expect(info.identifier == String(ProcessInfo.processInfo.processIdentifier))
        #expect(info.names.unlocalized.base == ProcessInfo.processInfo.processName)
        #expect(info.names.unlocalized.display == nil)
        #expect(info.names.localized.base == nil)
        #expect(info.names.localized.display == nil)
        #expect(info.versioning.version == "1.0.0")
        #expect(info.versioning.build == "1")
        #expect(info.copyright == nil)
        #expect(info.appleID == "12345")
    }

    @Test
    func creationFromUnlocalizedBundle() throws {
        try fillBundle(identifier: "test-identifier",
                       infoDict: [
                        "CFBundleShortVersionString": "1.2.3",
                        "CFBundleVersion": "42",
                        "CFBundleName": "TestName",
                        "CFBundleDisplayName": "Test Display Name",
                        "NSHumanReadableCopyright": "Some Copyright",
                        "AppInformationAppleID": "54321",
                       ])
        let bundle = try #require(Bundle(path: bundlePath))
        let info = AppInfo(bundle: bundle)

        #expect(info.identifier == "test-identifier")
        #expect(info.names.unlocalized.base == "TestName")
        #expect(info.names.unlocalized.display == "Test Display Name")
        #expect(info.names.localized.base == nil)
        #expect(info.names.localized.display == nil)
        #expect(info.versioning.version == "1.2.3")
        #expect(info.versioning.build == "42")
        #expect(info.copyright == "Some Copyright")
        #expect(info.appleID == "54321")
    }

    @Test
    func creationFromLocalizedBundle() throws {
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
        let bundle = try #require(Bundle(path: bundlePath))
        let info = AppInfo(bundle: bundle)

        #expect(info.identifier == "test-identifier")
        #expect(info.names.unlocalized.base == "TestName")
        #expect(info.names.unlocalized.display == "Test Display Name")
        #expect(info.names.localized.base == "LocalizedTestName")
        #expect(info.names.localized.display == "Localized Test Display Name")
        #expect(info.versioning.version == "1.2.3")
        #expect(info.versioning.build == "42")
        #expect(info.copyright == "Some Localized Copyright")
        #expect(info.appleID == "54321")
    }

    @Test
    func identifiableConformance() throws {
        try fillBundle()
        let info = try AppInfo(bundle: #require(Bundle(path: bundlePath)))
        #expect(info.id == info.identifier)
    }

    @Test
    func namingAccessors() {
        #expect(AppInfo.Naming(unlocalized: (base: "relevant", display: nil), localized: (nil, nil)).effectiveName == "relevant")
        #expect(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "relevant"), localized: (nil, nil)).effectiveName == "relevant")
        #expect(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"), localized: ("relevant", nil)).effectiveName == "relevant")
        #expect(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"), localized: ("not-relevant", "relevant")).effectiveName == "relevant")
        #expect(AppInfo.Naming(unlocalized: (base: "relevant", display: nil), localized: (nil, nil)).effective == ("relevant", nil))
        #expect(AppInfo.Naming(unlocalized: (base: "relevant", display: "also-relevant"),localized: (nil, nil)).effective == ("relevant", "also-relevant"))
        #expect(AppInfo.Naming(unlocalized: (base: "relevant", display: "not-relevant"), localized: (nil, "also-relevant")).effective == ("relevant", "also-relevant"))
        #expect(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "also-relevant"), localized: ("relevant", nil)).effective == ("relevant", "also-relevant"))
        #expect(AppInfo.Naming(unlocalized: (base: "not-relevant", display: "not-relevant"), localized: ("relevant", "also-relevant")).effective == ("relevant", "also-relevant"))
    }

    @Test
    func namingEquatableConformance() {
        let naming1 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: (nil, nil))
        let naming2 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: ("loc-base", nil))
        let naming3 = AppInfo.Naming(unlocalized: ("base-name", "display-name"), localized: (nil, nil))
        #expect(naming1 == naming3)
        #expect(naming1 != naming2)
        #expect(naming2 != naming3)
    }

    @Test
    func versioningAccessors() {
        let versioning = AppInfo.Versioning(version: "1.2.3", build: "42")
        #expect(versioning.combined == "1.2.3 (42)")
    }

    @Test(.enabled {
#if canImport(SwiftUI)
        true
#else
        false
#endif
    })
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func swiftUIEnvironment() throws {
#if canImport(SwiftUI)
        let info = try AppInfo(bundle: #require(Bundle(path: bundlePath)))
        var env = EnvironmentValues()
        #expect(env.appInfo == .current)
        env.appInfo = info
        #expect(env.appInfo == info)
#endif
    }
}

