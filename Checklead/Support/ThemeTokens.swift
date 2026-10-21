import SwiftUI

/// Typed reach into DesignTokens. Radii, spacing, and the one shadow live here.
enum ThemeTokens {
    static let space: CGFloat = 8
    static let cardRadius: CGFloat = 28
    static let chipRadius: CGFloat = 14
    static let pressScale: CGFloat = 0.97
    static let pressDuration: Double = 0.16
    static let sheetDuration: Double = 0.24
    static let sheetScale: CGFloat = 0.96
    static let rule: CGFloat = 2

    static let shadow = Color.black.opacity(0.12)
    static let shadowRadius: CGFloat = 12
    static let shadowY: CGFloat = 6

    static func font(_ step: TypeStep) -> Font {
        Font.custom(DesignTokens.fontFamily, size: step.size, relativeTo: step.textStyle)
    }

    enum TypeStep {
        case display
        case title
        case body
        case caption
        case figure
        case micro

        var size: CGFloat {
            switch self {
            case .display: 34
            case .title: 22
            case .body: 17
            case .caption: 15
            case .figure: 20
            case .micro: 13
            }
        }

        var textStyle: Font.TextStyle {
            switch self {
            case .display: .largeTitle
            case .title: .title2
            case .body: .body
            case .caption: .callout
            case .figure: .title3
            case .micro: .footnote
            }
        }
    }
}

struct PaperShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: ThemeTokens.shadow, radius: ThemeTokens.shadowRadius, x: 0, y: ThemeTokens.shadowY)
    }
}

struct ProminentPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeTokens.font(.body))
            .padding(.horizontal, ThemeTokens.space * 2)
            .padding(.vertical, ThemeTokens.space)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(DesignTokens.bg)
            .background(DesignTokens.accent, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .paperShadow()
            .contentShape(RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion && isEnabled ? ThemeTokens.pressScale : 1)
            .opacity(!isEnabled ? 0.4 : (configuration.isPressed && reduceMotion ? 0.72 : 1))
            .animation(.easeOut(duration: ThemeTokens.pressDuration), value: configuration.isPressed)
    }
}

struct SecondaryPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeTokens.font(.body))
            .padding(.horizontal, ThemeTokens.space * 2)
            .padding(.vertical, ThemeTokens.space)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(DesignTokens.ink)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .paperShadow()
            .contentShape(RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion && isEnabled ? ThemeTokens.pressScale : 1)
            .opacity(!isEnabled ? 0.4 : (configuration.isPressed && reduceMotion ? 0.72 : 1))
            .animation(.easeOut(duration: ThemeTokens.pressDuration), value: configuration.isPressed)
    }
}

struct SheetEntry: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion || shown ? 1 : ThemeTokens.sheetScale)
            .opacity(shown ? 1 : 0)
            .onAppear {
                if reduceMotion {
                    shown = true
                } else {
                    withAnimation(.easeOut(duration: ThemeTokens.sheetDuration)) {
                        shown = true
                    }
                }
            }
    }
}

struct PressScaleStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? ThemeTokens.pressScale : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(.easeOut(duration: ThemeTokens.pressDuration), value: configuration.isPressed)
    }
}

extension View {
    func paperShadow() -> some View { modifier(PaperShadow()) }

    func paperCard() -> some View {
        self
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous))
            .paperShadow()
    }
}
