import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// Printable collar sheet. Core Image draws the QR. The page is a stock share.
struct TagSheetPrinter {
    static func image(code: String, name: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(code.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        let context = CIContext()
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        let qr = UIImage(cgImage: cg)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 360, height: 480))
        return renderer.image { ctx in
            UIColor(DesignTokens.bg).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 360, height: 480))
            let title = name as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: DesignTokens.fontFamily, size: 28) ?? UIFont.systemFont(ofSize: 28),
                .foregroundColor: UIColor(DesignTokens.ink)
            ]
            title.draw(at: CGPoint(x: 24, y: 28), withAttributes: attrs)
            qr.draw(in: CGRect(x: 48, y: 100, width: 264, height: 264))
            let caption = code as NSString
            caption.draw(at: CGPoint(x: 24, y: 390), withAttributes: [
                .font: UIFont(name: DesignTokens.fontFamily, size: 17) ?? UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor(DesignTokens.muted)
            ])
        }
    }
}
