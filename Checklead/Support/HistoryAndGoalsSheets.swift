import SwiftUI

struct HistoryLogSheet: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    private var days: [Date] {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: vault.day)
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: end) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let error = vault.loadError {
                    retry(error) { vault.retryLoad() }
                        .padding(ThemeTokens.space * 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else if vault.ledger.marks.isEmpty {
                    VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                        Image("chl_EmptyHome")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 240)
                            .accessibilityHidden(true)
                        Text("No seats this week.")
                            .font(ThemeTokens.font(.display))
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Snap a chore on today.")
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                        Spacer(minLength: ThemeTokens.space)
                        Button("Show today") { dismiss() }
                            .buttonStyle(ProminentPressStyle())
                    }
                    .padding(ThemeTokens.space * 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                            Text("Week")
                                .font(ThemeTokens.font(.display))
                                .foregroundStyle(DesignTokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            matrix
                                .padding(ThemeTokens.space * 2)
                                .paperCard()
                            misses
                                .padding(ThemeTokens.space * 2)
                                .paperCard()
                        }
                        .padding(ThemeTokens.space * 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: vault.csv()) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Export week")
                }
            }
        }
    }

    private var matrix: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            HStack(spacing: ThemeTokens.space) {
                Text("Chore")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                    .frame(width: 72, alignment: .leading)
                ForEach(days, id: \.self) { day in
                    Text(dayNumber(day))
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .monospacedDigit()
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            ForEach(vault.ledger.routines.filter(\.isActive)) { routine in
                HStack(spacing: ThemeTokens.space) {
                    Text(routine.label)
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .frame(width: 72, alignment: .leading)
                    ForEach(days, id: \.self) { day in
                        let seated = isSeated(routine.id, on: day)
                        Image(systemName: seated ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(seated ? DesignTokens.accent : DesignTokens.muted)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityLabel(routine.label + " " + dayNumber(day) + (seated ? " seated" : " open"))
                    }
                }
            }
        }
    }

    private var misses: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            Text("Misses")
                .font(ThemeTokens.font(.title))
                .foregroundStyle(DesignTokens.ink)
            let misses = vault.ledger.marks.filter { $0.kind == .skew || $0.kind == .drift }
            if misses.isEmpty {
                Text("No wrong posts or early drags.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
            } else {
                ForEach(misses) { mark in
                    Text(line(mark))
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
            }
        }
    }

    private func isSeated(_ routineID: UUID, on day: Date) -> Bool {
        let key = RailFold.daykey(for: day)
        return vault.ledger.marks.contains { $0.kind == .seat && $0.daykey == key && $0.routineID == routineID }
    }

    private func dayNumber(_ day: Date) -> String {
        let value = Calendar.current.component(.day, from: day)
        return JauntFormat.tally(value)
    }

    private func line(_ mark: JauntMark) -> String {
        let pet = vault.ledger.pets.first { $0.id == mark.petID }?.name ?? ""
        let routine = vault.ledger.routines.first { $0.id == mark.routineID }?.label ?? ""
        return JauntFormat.daykeyText(mark.daykey) + " " + kindText(mark.kind) + " " + pet + " " + routine
    }

    private func kindText(_ kind: JauntMark.Kind) -> String {
        switch kind {
        case .tag: "Collar"
        case .seat: "Seated"
        case .skew: "Wrong post"
        case .drift: "Early drag"
        case .clip: "Clipped"
        }
    }
}

struct StreakGoalsSheet: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss

    private var seated: Int { vault.slots.filter { $0.post == .seated }.count }
    private var active: Int { max(vault.slots.count, 0) }

    private var nextTap: String {
        if let row = vault.slots.first(where: \.armed) {
            return "Snap " + row.label
        }
        return "Show today"
    }

    var body: some View {
        NavigationStack {
            Group {
                if let error = vault.loadError {
                    retry(error) { vault.retryLoad() }
                        .padding(ThemeTokens.space * 2)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                            Text("Streak")
                                .font(ThemeTokens.font(.body))
                                .foregroundStyle(DesignTokens.muted)
                            Text(JauntFormat.tally(vault.streak))
                                .font(ThemeTokens.font(.display))
                                .foregroundStyle(DesignTokens.ink)
                                .monospacedDigit()
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: true)
                            Text("Consecutive clipped days.")
                                .font(ThemeTokens.font(.body))
                                .foregroundStyle(DesignTokens.ink)
                            progressCard
                            yesterdayCard
                        }
                        .padding(ThemeTokens.space * 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .safeAreaInset(edge: .bottom, spacing: ThemeTokens.space * 2) {
                        Button(nextTap) { dismiss() }
                            .buttonStyle(ProminentPressStyle())
                            .padding(.horizontal, ThemeTokens.space * 2)
                            .padding(.bottom, ThemeTokens.space * 2)
                            .background(DesignTokens.bg)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            Text("Today")
                .font(ThemeTokens.font(.title))
                .foregroundStyle(DesignTokens.ink)
            Text(JauntFormat.tally(seated) + " of " + JauntFormat.tally(active) + " seated")
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
                .monospacedDigit()
            GeometryReader { geo in
                let fraction = active == 0 ? 0 : CGFloat(seated) / CGFloat(active)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                        .fill(DesignTokens.bg)
                    RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                        .fill(DesignTokens.accent)
                        .frame(width: max(ThemeTokens.space, geo.size.width * fraction))
                }
            }
            .frame(height: ThemeTokens.space * 2)
            .accessibilityLabel(JauntFormat.tally(seated) + " seated of " + JauntFormat.tally(active))
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .paperCard()
    }

    private var yesterdayCard: some View {
        HStack(alignment: .center, spacing: ThemeTokens.space * 2) {
            Image("chl_ClippedSealStamp")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text("Yesterday")
                    .font(ThemeTokens.font(.title))
                    .foregroundStyle(DesignTokens.ink)
                Text(vault.streak == 0 ? "Today is still open. Seat the remaining chores to grow the run." : "The run is live. Keep every active chore seated.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .paperCard()
    }
}

struct SettingsSheet: View {
    @ObservedObject var vault: JauntVault
    @Binding var showOnboarding: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Group {
                if let error = vault.loadError {
                    retry(error) { vault.retryLoad() }
                        .padding(ThemeTokens.space * 2)
                } else {
                    Form {
                        Section {
                            Button("Show intro again") {
                                showOnboarding = true
                                dismiss()
                            }
                            .frame(minHeight: 44)
                            Button("Reset household") { confirmReset = true }
                                .foregroundStyle(DesignTokens.ink)
                                .frame(minHeight: 44)
                            if let contact = URL(string: "https://checklead-rail.pro/contact-us") {
                                Link("Contact support", destination: contact)
                                    .frame(minHeight: 44)
                            }
                        }
                        Section("Camera") {
                            Text("Collar scan uses the camera. If it is off, use Open Settings.")
                                .font(ThemeTokens.font(.body))
                                .foregroundStyle(DesignTokens.ink)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .frame(minHeight: 44)
                        }
                        #if targetEnvironment(simulator)
                        Section {
                            Button("Restore demo household") { vault.reseedDemo() }
                                .frame(minHeight: 44)
                        }
                        #endif
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.frame(minHeight: 44)
                }
            }
            .confirmationDialog("Reset household?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset all data", role: .destructive) { vault.resetAllData() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

func retry(_ message: String, action: @escaping () -> Void) -> some View {
    VStack(alignment: .leading, spacing: ThemeTokens.space) {
        Text(message)
            .font(ThemeTokens.font(.body))
            .foregroundStyle(DesignTokens.ink)
            .fixedSize(horizontal: false, vertical: true)
        Button("Retry", action: action)
            .buttonStyle(ProminentPressStyle())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
