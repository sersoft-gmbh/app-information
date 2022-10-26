#if arch(arm64) || arch(x86_64)
#if canImport(Combine) && canImport(SwiftUI)
import SwiftUI

/// A view that shows an application icon next to the application details (name and version).
/// The application info is read from the environment.
/// - SeeAlso: ``AppIconView``
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ApplicationInfoView: View {
    @Environment(\.appInfo)
    private var appInfo

    private var iconHeight: CGFloat { 100 }

    public var body: some View {
        HStack {
            Spacer()
            AppIconView()
                .rounded(withHeight: iconHeight)
                .padding(.horizontal)
            Spacer()
            VStack(spacing: 10) {
                Text(appInfo.names.effectiveName).font(.appName)
                Text(appInfo.versioning.combined).font(.version)
            }
            .padding(.horizontal)
            Spacer()
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

    static var version: Font { .subheadline }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct ApplicationInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationInfoView()
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
#endif
