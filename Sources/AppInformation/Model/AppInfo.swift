import class Foundation.Bundle
import class Foundation.ProcessInfo

/// Contains the information for an application (e.g. naming and versioning).
public struct AppInfo: Equatable, Identifiable {
    /// The naming information.
    public struct Naming: Equatable {
        /// The unlocalized set of names.
        public let unlocalized: (base: String, display: String?)
        /// The localized set of names.
        public var localized: (base: String?, display: String?)

        /// Returns the effective set of names, combining values from ``unlocalized`` and ``localized``.
        public var effective: (base: String, display: String?) {
            (base: localized.base ?? unlocalized.base,
             display: localized.display ?? unlocalized.display)
        }

        /// The effective name of this naming instance.
        /// This uses the names in the following order of precedence:
        /// - localized display name
        /// - localized base name
        /// - unlocalized display name
        /// - unlocalized base name
        public var effectiveName: String { localized.display ?? localized.base ?? unlocalized.display ?? unlocalized.base }

        /// See `Equatable.==`
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.unlocalized == rhs.unlocalized && lhs.localized == rhs.localized
        }
    }

    /// The versioning information.
    public struct Versioning: Equatable {
        /// The version, e.g. 1.0.0.
        public let version: String
        /// The build, e.g. 42.
        public let build: String

        /// The combined version information, formatted as "<Version> (<Build>)"
        public var combined: String { "\(version) (\(build))" }
    }

    /// The identifier of this application.
    public let identifier: String
    /// The naming information.
    public var names: Naming
    /// The versioning information.
    public var versioning: Versioning

    /// The copyright information.
    public var copyright: String?

    /// The appleID of the application.
    public var appleID: AppleID?

    /// See `Identifiable.id`.
    @inlinable
    public var id: String { identifier }
}

extension AppInfo {
    /// Creates a new information reading the infos from the given bundle.
    /// - Parameter bundle: The bundle to read the information from.
    /// - Parameter appleID: The appleID to use. Defaults to `nil`, in which case it is attempted to read it
    ///                      from the `AppInformationAppleID` key in the bundle's info dictionary.
    public init(bundle: Bundle, appleID: AppleID? = nil) {
        let infoDict = bundle.infoDictionary ?? [:]
        identifier = bundle.bundleIdentifier ?? String(ProcessInfo.processInfo.processIdentifier)
        names = Naming(infoDict: infoDict, localizedInfoDict: bundle.localizedInfoDictionary)
        versioning = Versioning(infoDict: infoDict)

        func readCopyright(from infoDict: Dictionary<String, Any>?) -> String? {
            infoDict?["NSHumanReadableCopyright"] as? String
        }
        copyright = readCopyright(from: bundle.localizedInfoDictionary) ?? readCopyright(from: infoDict)

        self.appleID = appleID ?? (infoDict["AppInformationAppleID"] as? String).map { AppleID(rawValue: $0) }
    }
}

extension AppInfo.Naming {
    private static func readBaseName(from infoDict: Dictionary<String, Any>) -> String? {
        infoDict["CFBundleName"] as? String
    }

    private static func readDisplayName(from infoDict: Dictionary<String, Any>) -> String? {
        infoDict["CFBundleDisplayName"] as? String
    }

    init(infoDict: Dictionary<String, Any>, localizedInfoDict: Dictionary<String, Any>?) {
        self.init(
            unlocalized: (
                base: Self.readBaseName(from: infoDict) ?? ProcessInfo.processInfo.processName,
                display: Self.readDisplayName(from: infoDict)
            ),
            localized: localizedInfoDict.map {
                (
                    base: Self.readBaseName(from: $0),
                    display: Self.readDisplayName(from: $0)
                )
            } ?? (base: nil, display: nil)
        )
    }
}

extension AppInfo.Versioning {
    init(infoDict: Dictionary<String, Any>) {
        version = infoDict["CFBundleShortVersionString"] as? String ?? "1.0.0"
        build = infoDict["CFBundleVersion"] as? String ?? "1"
    }
}

extension AppInfo {
    /// The application info of the current application.
    public static let current = AppInfo(bundle: .main)
}

#if arch(arm64) || arch(x86_64)
#if canImport(Combine) && canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AppInfo {
    @frozen
    @usableFromInline
    enum EnvKey: EnvironmentKey {
        @usableFromInline
        typealias Value = AppInfo

        @usableFromInline
        static var defaultValue: Value { .current }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The environment's application information. Defaults to the current application's information.
    /// Note that if you want to specify the app's AppleID in code, you can use `View.transformEnvironment`
    /// to be able to modify the current app info and for example set the ``AppInfo/appleID`` property.
    @inlinable
    public var appInfo: AppInfo {
        get { self[AppInfo.EnvKey.self] }
        set { self[AppInfo.EnvKey.self] = newValue }
    }
}
#endif
#endif

#if compiler(>=5.5.2) && canImport(_Concurrency)
extension AppInfo: Sendable {}
extension AppInfo.Naming: Sendable {}
extension AppInfo.Versioning: Sendable {}
#endif
