import SwiftUI

/// Open chores. Each row seats the chore or marks its post on Today.
struct DiscScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    private var openRows: [SlotRow] { vault.slots.filter { $0.post != .seated } }
    private var focus: SlotRow? { openRows.first(where: \.armed) ?? openRows.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                    Text(headline)
                        .font(ThemeTokens.font(.display))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(instruction)
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if let focus {
                        choreButton(focus, prominent: true)
                    }
                    ForEach(openRows.filter { $0.id != focus?.id }) { row in
                        choreButton(row, prominent: false)
                    }
                }
                .padding(ThemeTokens.space * 2)
            }
            .background(DesignTokens.bg)
            .navigationTitle("Open chores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }

    private var headline: String {
        guard let focus else { return "Open chores" }
        if focus.armed { return "Seat " + focus.label }
        return "Show " + focus.label
    }

    private var instruction: String {
        guard let focus else { return "Every chore is seated." }
        if focus.armed {
            return "Tap Seat " + focus.label + ". It lands on " + focus.petName + "'s post."
        }
        return "Tap Show on Today. " + focus.label + " lights up on the day column."
    }

    @ViewBuilder
    private func choreButton(_ row: SlotRow, prominent: Bool) -> some View {
        if prominent {
            choreControl(row).buttonStyle(ProminentPressStyle())
        } else {
            choreControl(row).buttonStyle(SecondaryPressStyle())
        }
    }

    private func choreControl(_ row: SlotRow) -> some View {
        Button {
            if row.armed {
                _ = vault.release(routineID: row.routineID, onto: row.routineID)
            } else {
                vault.showOnToday(row.routineID)
                dismiss()
            }
        } label: {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text(row.petName + " · " + row.window)
                    .font(ThemeTokens.font(.body))
                    .lineLimit(1)
                Text(verb(row))
                    .font(ThemeTokens.font(.title))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(verb(row))
    }

    private func verb(_ row: SlotRow) -> String {
        row.armed ? "Seat " + row.label : "Show " + row.label + " on Today"
    }
}

/// Tray page. The same dynamics stage sits on a tall plate.
struct DockScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                    Text("Tray")
                        .font(ThemeTokens.font(.display))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Drag a chore upward. A matching post keeps it. A miss springs it home.")
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    DockBarView(discs: tokens, phase: vault.phase) {
                        DynamicsDockRepresentable(
                            discs: tokens,
                            slotFrames: [:],
                            reduceMotion: reduceMotion,
                            onRelease: { id, target in
                                vault.release(routineID: id, onto: target)
                            }
                        )
                    }
                }
                .padding(ThemeTokens.space * 2)
                .padding(.bottom, ThemeTokens.space * 6)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(DesignTokens.bg)
            .navigationTitle("Tray")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }

    private var tokens: [DiscToken] {
        let seated = Set(vault.slots.filter { $0.post == .seated }.map(\.routineID))
        return vault.ledger.routines.filter(\.isActive).filter { !seated.contains($0.id) }.map {
            DiscToken(id: $0.id, label: $0.label, enabled: vault.phase != .clipped && vault.phase != .blank)
        }
    }
}
