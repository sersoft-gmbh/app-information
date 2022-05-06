#if arch(arm64) || arch(x86_64)
#if canImport(Combine) && canImport(SwiftUI)
import SwiftUI

/// Describes the mode how the app icon should be displayed.
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum AppIconMode {
    /// Describes how a composed app icon should be padded.
    public enum CompositionPadding {
        /// Apply default padding. Calls `padding()`.
        case standard
        /// Apply custom insets. Calls `padding(insets)`
        case insets(EdgeInsets)
        /// Apply an padding at the given edges. Calls `padding(edges, value)`
        case edges(Edge.Set, value: CGFloat?)
    }

    /// Use a prerendered image (e.g. bundled in the app's assets).
    case prerendered(Image)
    /// Compose the icon using the given `logoImage` (foreground) tinted with the `logoColor`
    /// and `backgroundColor`. The `logoImage` will be inset by `logoPadding`.
    case composed(logoImage: Image,
                  logoColor: Color?,
                  logoPadding: CompositionPadding?,
                  backgroundColor: Color)
    /// Use an app icon template. The `accentColor` is used to color the template.
    case template
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AppIconMode {
    @frozen
    @usableFromInline
    enum EnvKey: EnvironmentKey {
        @usableFromInline
        typealias Value = AppIconMode

        @usableFromInline
        static var defaultValue: Value { .template }
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The app icon mode. Defaults to ``AppIconMode/template``.
    @inlinable
    public var appIconMode: AppIconMode {
        get { self[AppIconMode.EnvKey.self] }
        set { self[AppIconMode.EnvKey.self] = newValue }
    }
}

/// A simple view showing the app icon using the ``AppIconMode`` of the environment.
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AppIconView: View {
    @Environment(\.appIconMode)
    private var mode

    /// See `View.body`.
    public var body: some View {
        switch mode {
        case .prerendered(let img):
            img
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .composed(let logoImage, let logoColor, let logoPadding, let logoBackgroundColor):
            logoImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(logoColor)
                .padding(logoPadding)
                .background(logoBackgroundColor)
        case .template:
            Image(systemName: "app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .overlay(
                    Image(systemName: "a.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                        .padding()
                )
        }
    }

    /// Creates a new app icon mode.
    public init() {}

    /// Applies the given height as `frame(height: height)` and calculates
    /// the correct rounding for this height.
    /// - Parameter height: The height this icon should be displayed in.
    public func rounded(withHeight height: CGFloat) -> some View {
        frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: (10 / 57) * height))
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
fileprivate extension AppIconMode.CompositionPadding {
    struct Modifier: ViewModifier {
        let padding: AppIconMode.CompositionPadding?

        @ViewBuilder
        func body(content: Content) -> some View {
            switch padding {
            case .none: content
            case .standard: content.padding()
            case .insets(let insets): content.padding(insets)
            case .edges(let edges, let value): content.padding(edges, value)
            }
        }
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
fileprivate extension View {
    func padding(_ padding: AppIconMode.CompositionPadding?) -> some View {
        modifier(AppIconMode.CompositionPadding.Modifier(padding: padding))
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
#endif
#endif
