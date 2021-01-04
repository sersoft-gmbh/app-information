import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem

extension AppInfo {
    /// Represents an AppleID of an application (usually a numerical value).
    @frozen
    public struct AppleID: RawRepresentable, ExpressibleByStringLiteral, Hashable, Codable {
        /// See `RawRepresentable.RawValue`.
        public typealias RawValue = String
        /// See `ExpressibleByStringLiteral.StringLiteralType`.
        public typealias StringLiteralType = RawValue.StringLiteralType

        private static let appStoreBaseURL = URL(string: "https://apps.apple.com/app/")!

        /// See `RawRepresentable.rawValue`
        public let rawValue: RawValue

        /// The app store url for this AppleID.
        public var appStoreURL: URL {
            Self.appStoreBaseURL.appendingPathComponent("id\(rawValue)")
        }

        /// The review url for this AppleID.
        public var reviewURL: URL {
            var comps = URLComponents(url: appStoreURL, resolvingAgainstBaseURL: true)!
            comps.queryItems = (comps.queryItems ?? [])
                + CollectionOfOne(URLQueryItem(name: "action", value: "write-review"))
            return comps.url!
        }

        /// See `RawRepresentable.init(rawValue:)`
        /// - Parameter rawValue: The raw apple id.
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// See `ExpressibleByStringLiteral.init(stringLiteral:)`
        /// - Parameter value: The string literal value.
        @inlinable
        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
    }
}
