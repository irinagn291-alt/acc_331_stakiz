import SwiftUI

/// Timeline of posts. Frames are reported so the tray can snap chores onto them.
struct SlotFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] { [:] }
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct SlotTimelineView: View {
    var slots: [SlotRow]
    var spotlightID: UUID? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var focusID: UUID? { slots.first(where: \.armed)?.routineID }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            rail(AnyLayout(HStackLayout(alignment: .top, spacing: ThemeTokens.space * 2)))
            rail(AnyLayout(VStackLayout(alignment: .leading, spacing: ThemeTokens.space * 2)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rail(_ layout: AnyLayout) -> some View {
        layout {
            ForEach(grouped.keys.sorted(), id: \.self) { name in
                VStack(alignment: .leading, spacing: ThemeTokens.space) {
                    Text(name)
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                    posts(grouped[name] ?? [])
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var grouped: [String: [SlotRow]] {
        Dictionary(grouping: slots, by: \.petName)
    }

    @ViewBuilder
    private func posts(_ rows: [SlotRow]) -> some View {
        if sizeClass == .regular {
            HStack(alignment: .top, spacing: ThemeTokens.space) {
                ForEach(rows) { slot in
                    post(slot)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                ForEach(rows) { slot in
                    post(slot)
                }
            }
        }
    }

    @ViewBuilder
    private func post(_ slot: SlotRow) -> some View {
        let body = plate(slot)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SlotFrameKey.self,
                        value: [slot.routineID: proxy.frame(in: .global)]
                    )
                }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(slot.petName + " " + slot.label + " " + (slot.post == .seated ? "seated" : "open"))
        body
    }

    @ViewBuilder
    private func plate(_ slot: SlotRow) -> some View {
        if slot.post == .seated {
            HStack(spacing: ThemeTokens.space) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DesignTokens.accent)
                    .accessibilityHidden(true)
                Text(slot.label)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Spacer(minLength: ThemeTokens.space)
                Text("Seated")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
        } else if slot.routineID == focusID {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text(slot.window)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                Text(slot.label)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Ready")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .padding(.horizontal, ThemeTokens.space)
                    .frame(minHeight: 44)
                    .background(DesignTokens.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .fixedSize(horizontal: false, vertical: true)
            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                    .stroke(DesignTokens.accent, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
        } else if slot.armed {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text(slot.window)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                Text(slot.label)
                    .font(ThemeTokens.font(.title))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Also open")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .fixedSize(horizontal: false, vertical: true)
            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                    .stroke(DesignTokens.accent, lineWidth: 2)
            )
            .overlay(spotlightStroke(slot))
        } else {
            HStack(spacing: ThemeTokens.space) {
                Image(systemName: "circle")
                    .foregroundStyle(DesignTokens.muted)
                    .accessibilityHidden(true)
                Text(slot.label)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                Spacer(minLength: ThemeTokens.space)
                Text("Hold")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .overlay(spotlightStroke(slot))
        }
    }

    @ViewBuilder
    private func spotlightStroke(_ slot: SlotRow) -> some View {
        if slot.routineID == spotlightID {
            RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                .stroke(DesignTokens.accent, lineWidth: 3)
        }
    }
}

/// Full-page post timeline for the cover driver.
struct SlotScreen: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                    Text("Posts")
                        .font(ThemeTokens.font(.display))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Each chore has one post for today. Ready posts take the next drag.")
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    SlotTimelineView(slots: vault.slots)
                        .padding(ThemeTokens.space * 2)
                        .paperCard()
                }
                .padding(ThemeTokens.space * 2)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(DesignTokens.bg)
            .navigationTitle("Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }
}
