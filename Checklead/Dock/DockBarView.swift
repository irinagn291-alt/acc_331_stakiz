import SwiftUI

/// Tray plate. Caption sits in its own row; the chip lane is the row under it.
struct DockBarView<Stage: View>: View {
    var discs: [DiscToken]
    var phase: RailFoldState
    @ViewBuilder var stage: () -> Stage

    var body: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
            Text(caption)
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            stage()
                .frame(height: 72)
                .frame(maxWidth: .infinity, maxHeight: 72, alignment: .leading)
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .paperCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(caption)
        .accessibilityHint(discs.map(\.label).joined(separator: ", "))
    }

    private var caption: String {
        switch phase {
        case .blank: "Add a pet, then a chore."
        case .open: "Scan a collar before you drag."
        case .snapping: "Drag the open chore onto the glowing post above."
        case .clipped: "Clipped. Undo the last seat to reopen."
        }
    }
}
