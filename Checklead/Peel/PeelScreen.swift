import SwiftUI

/// Lifts the latest seat and reopens the day when a post is bare again.
struct PeelScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    private var lastSeat: String {
        let seats = vault.ledger.marks.filter { $0.kind == .seat && $0.daykey == vault.daykey }
        guard let mark = seats.last else { return "No seat yet" }
        return vault.ledger.routines.first { $0.id == mark.routineID }?.label ?? "Last seat"
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                Text("Undo seat")
                    .font(ThemeTokens.font(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(lastSeat)
                    .font(ThemeTokens.font(.title))
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Lifts the last seated chore and reopens the day.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Image("chl_TwistHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .padding(ThemeTokens.space * 2)
                    .paperCard()
                    .accessibilityHidden(true)
                Spacer(minLength: ThemeTokens.space)
                Button("Undo seat") { vault.peel() }
                    .buttonStyle(ProminentPressStyle())
                    .disabled(lastSeat == "No seat yet")
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Undo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }
}
