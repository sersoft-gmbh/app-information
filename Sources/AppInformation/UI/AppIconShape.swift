#if canImport(SwiftUI)
public import SwiftUI

/// A shape that represents the application icon shape, which is typically a rounded rectangle with a specific corner radius.
/// This shape is platform specific. On visionOS and watchOS, it is a circle.
@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AppIconShape: InsettableShape {
    public typealias InsetShape = Self

    private var insetAmount: CGFloat = 0

    /// Creates a new   ``AppIconShape``.
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let minSize = min(rect.width, rect.height)
#if !os(tvOS)
        let shapeRect = CGRect(origin: rect.origin,
                             size: .init(width: minSize,
                                         height: minSize))
#else
        let shapeRect = rect
#endif
        let insetRect = shapeRect.insetBy(dx: insetAmount, dy: insetAmount)
#if os(visionOS) || os(watchOS)
        return Path(ellipseIn: insetRect)
#else
        let radiusSize = minSize - insetAmount
        let radius: CGFloat
        if #available(macOS 26, iOS 26, tvOS 26, *) {
            radius = radiusSize * 16.5 / 64
        } else {
            radius = radiusSize / 2 * 0.4453125
        }
        return Path(roundedRect: insetRect,
                    cornerRadius: radius,
                    style: .continuous)
#endif
    }

    public func inset(by amount: CGFloat) -> AppIconShape {
        var newSelf = self
        newSelf.insetAmount += amount
        return newSelf
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
#Preview {
    VStack(alignment: .center) {
        AppIconShape()
            .fill(Color.accentColor)
            .scaledToFit()
        Color.green
            .clipShape(AppIconShape())
            .scaledToFit()
    }
}
#endif
