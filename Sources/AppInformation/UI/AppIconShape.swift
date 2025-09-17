#if canImport(SwiftUI)
public import SwiftUI

/// A shape that represents the application icon shape, which is typically a rounded rectangle with a specific corner radius.
/// This shape is platform specific. On visionOS and watchOS, it is a circle.
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AppIconShape: Shape {
    /// Creates a new   ``AppIconShape``.
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let minSize = min(rect.width, rect.height)
#if !os(tvOS)
        let minRect = CGRect(origin: rect.origin,
                             size: .init(width: minSize,
                                         height: minSize))
#endif
#if os(visionOS) || os(watchOS)
        return Path(ellipseIn: minRect)
#else
        let radius: CGFloat
        if #available(macOS 26, iOS 26, tvOS 26, *) {
            radius = minSize * 16.5 / 64
        } else {
            radius = minSize / 2 * 0.4453125
        }
#if os(tvOS)
        let shapeRect = rect
#else
        let shapeRect = minRect
#endif
        return Path(roundedRect: shapeRect,
                    cornerRadius: radius,
                    style: .continuous)
#endif
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
#Preview {
    AppIconShape()
        .fill(Color.accentColor)
}
#endif
