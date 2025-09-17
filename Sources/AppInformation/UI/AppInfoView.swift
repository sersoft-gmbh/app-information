#if canImport(SwiftUI)
public import SwiftUI

/// A view that shows an application icon next to the application details (name and version).
/// The application info is read from the environment.
/// - SeeAlso: ``AppIconView``,
/// - SeeAlso: ``ApplicationDetailsView``
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ApplicationInfoView: View {
    @Environment(\.appInfo)
    private var appInfo

    public var body: some View {
        HStack {
            Spacer()
            AppIconView()
                .frame(maxHeight: 100)
                .padding(.horizontal)
            Spacer()
            ApplicationDetailsView()
                .padding(.horizontal)
            Spacer()
        }
    }

    /// Creates a new ``ApplicationInfoView``.
    public init() {}
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
#Preview {
    ApplicationInfoView()
        .environment(\.appInfo,
                      .init(identifier: "de.sersoft.testapp",
                            names: .init(unlocalized: (base: "TestApp",
                                                       display: "Test App"),
                                         localized: (nil, nil)),
                            versioning: .init(version: "1.0.0", build: "1")
                           ))
        .environment(\.appIconMode,
                      .prerendered(Image(systemName: "squareshape.fill")))
}
#endif
