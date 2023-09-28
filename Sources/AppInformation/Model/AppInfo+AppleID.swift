import struct Foundation.URL
import struct Foundation.URLQueryItem
import struct Foundation.URLComponents

extension AppInfo {
    /// Represents an AppleID of an application (usually a numerical value).
    @frozen
    public struct AppleID: RawRepresentable, Sendable, ExpressibleByStringLiteral, Hashable, Codable {
        public typealias RawValue = String
        public typealias StringLiteralType = RawValue.StringLiteralType

        private static let appStoreBaseURL = URL(string: "https://apps.apple.com/app/")!

        public let rawValue: RawValue

        /// The app store url for this AppleID.
        public var appStoreURL: URL {
            let component = "id\(rawValue)"
#if canImport(Darwin)
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                return Self.appStoreBaseURL.appending(component: component)
            } else {
                return Self.appStoreBaseURL.appendingPathComponent(component)
            }
#else
            return Self.appStoreBaseURL.appendingPathComponent(component)
#endif
        }

        /// The review url for this AppleID.
        public var reviewURL: URL {
            let queryItem = URLQueryItem(name: "action", value: "write-review")
            func _legacy() -> URL {
                var comps = URLComponents(url: appStoreURL, resolvingAgainstBaseURL: false)!
                comps.queryItems = (comps.queryItems ?? []) + CollectionOfOne(queryItem)
                return comps.url!
            }
#if canImport(Darwin)
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                return appStoreURL.appending(queryItems: [queryItem])
            } else {
                return _legacy()
            }
#else
            return _legacy()
#endif
        }

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        @inlinable
        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
    }
}
