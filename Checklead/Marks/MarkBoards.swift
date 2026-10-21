import SwiftUI

struct SkewMarkScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    private var rows: [JauntMark] { vault.ledger.marks.filter { $0.kind == .skew } }

    var body: some View {
        markPage(title: "Wrong posts", detail: "A chore released on the wrong post lands here.", rows: rows, empty: "No wrong posts.")
    }

    @ViewBuilder
    private func markPage(title: String, detail: String, rows: [JauntMark], empty: String) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                Text(title)
                    .font(ThemeTokens.font(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if rows.isEmpty {
                    Spacer(minLength: ThemeTokens.space)
                    Text(empty)
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.muted)
                    Button("Show today") { dismiss() }
                        .buttonStyle(ProminentPressStyle())
                } else {
                    ForEach(rows) { mark in
                        Text(line(mark))
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .padding(.horizontal, ThemeTokens.space * 2)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                    }
                    Spacer(minLength: ThemeTokens.space)
                }
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }

    private func line(_ mark: JauntMark) -> String {
        let routine = vault.ledger.routines.first { $0.id == mark.routineID }?.label ?? ""
        return JauntFormat.daykeyText(mark.daykey) + " " + routine
    }
}

struct DriftMarkScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            let rows = vault.ledger.marks.filter { $0.kind == .drift }
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                Text("Early drags")
                    .font(ThemeTokens.font(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A drag before any collar read is kept here.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if rows.isEmpty {
                    Image("chl_EmptyHome")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .accessibilityHidden(true)
                    Spacer(minLength: ThemeTokens.space)
                    Text("No early drags.")
                        .font(ThemeTokens.font(.body))
                    Button("Show today") { dismiss() }
                        .buttonStyle(ProminentPressStyle())
                } else {
                    ForEach(rows) { mark in
                        let routine = vault.ledger.routines.first { $0.id == mark.routineID }?.label ?? ""
                        Text(JauntFormat.daykeyText(mark.daykey) + " " + routine)
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .padding(.horizontal, ThemeTokens.space * 2)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Early drags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }
}

struct ClipMarkScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                Image("chl_ClippedSealStamp")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .accessibilityLabel("Clipped seal")
                Text(JauntFormat.tally(vault.streak))
                    .font(ThemeTokens.font(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                Text("Days that clipped shut, counted backward from today.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                let clips = vault.ledger.marks.filter { $0.kind == .clip }
                ForEach(clips) { mark in
                    Text(JauntFormat.daykeyText(mark.daykey))
                        .font(ThemeTokens.font(.figure))
                        .foregroundStyle(DesignTokens.ink)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
                Spacer(minLength: ThemeTokens.space)
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Clipped days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }
}
