import AppKit

enum MenuBarIcon {
    private static let canvasSize = NSSize(width: 18, height: 18)

    static func image(enabled: Bool) -> NSImage {
        let image = NSImage(size: canvasSize, flipped: false) { _ in
            draw(enabled: enabled)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = enabled ? "TidyUp" : "TidyUp paused"
        return image
    }

    private static func draw(enabled: Bool) {
        guard let context = NSGraphicsContext.current else { return }
        let cgContext = context.cgContext
        cgContext.saveGState()
        cgContext.setAlpha(enabled ? 1 : 0.4)
        cgContext.beginTransparencyLayer(auxiliaryInfo: nil)
        NSColor.black.set()

        let trail = NSBezierPath(roundedRect: NSRect(x: 1, y: 0.75, width: 7.5, height: 1.5), xRadius: 0.75, yRadius: 0.75)
        trail.fill()

        context.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.translateX(by: 10.4, yBy: 10.4)
        transform.rotate(byDegrees: 45)
        transform.concat()

        let lineWidth: CGFloat = 1.5
        let body = NSRect(x: -6.6, y: -3.6, width: 13.2, height: 7.2)
        let outline = NSBezierPath(
            roundedRect: body.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
            xRadius: 1.9,
            yRadius: 1.9
        )
        outline.lineWidth = lineWidth
        outline.stroke()

        let sleeveStart: CGFloat = -1.4
        NSBezierPath(rect: NSRect(x: sleeveStart, y: body.minY, width: body.maxX - sleeveStart, height: body.height)).addClip()
        NSBezierPath(roundedRect: body, xRadius: 2.6, yRadius: 2.6).fill()

        context.restoreGraphicsState()
        cgContext.endTransparencyLayer()
        cgContext.restoreGState()
    }
}
