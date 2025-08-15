#if canImport(SwiftUI)
public import SwiftUI

/// A view that shows the application details (name and version).
/// The application info is read from the environment.
/// - SeeAlso: ``AppIconView``
/// - SeeAlso: ``ApplicationInfoView``
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ApplicationDetailsView: View {
    @Environment(\.appInfo)
    private var appInfo

    public var body: some View {
        VStack(spacing: 10) {
            Text(appInfo.names.effectiveName)
                .font(.appName)
            Text(appInfo.versioning.combined)
                .font(.subheadline)
        }
    }

    /// Creates a new ``ApplicationInfoView``.
    public init() {}
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
fileprivate extension Font {
    static var appName: Font {
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return .title2
        } else {
            return .title
        }
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct ApplicationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationDetailsView()
            .environment(\.appInfo,
                          .init(identifier: "de.sersoft.testapp",
                                names: .init(unlocalized: (base: "TestApp",
                                                           display: "Test App"),
                                             localized: (nil, nil)),
                                versioning: .init(version: "1.0.0", build: "1")
                               ))
    }
}
#endif
