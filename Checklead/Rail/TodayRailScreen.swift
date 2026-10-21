import SwiftUI
import AVFoundation

/// Permanent root. The day column, the tray, and the streak stay mounted.
struct TodayRailScreen: View {
    @ObservedObject var vault: JauntVault
    @Binding var sheet: CoverSheet?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var displaySize: CGFloat = 34
    @State private var frames: [UUID: CGRect] = [:]
    @State private var cameraLive = false
    @State private var cameraDenied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                toolRow
                Text(headline)
                    .font(.custom(DesignTokens.fontFamily, size: displaySize, relativeTo: .largeTitle))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(vault.statusLine)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Rectangle()
                    .fill(DesignTokens.ink)
                    .frame(height: ThemeTokens.rule)
                    .accessibilityHidden(true)
                if let error = vault.loadError {
                    errorCard(error)
                }
                if vault.slots.isEmpty {
                    emptyRail(minHeight: ThemeTokens.space * 48)
                } else {
                    postColumn
                    tray
                    if let focus = focusSlot {
                        Button("Snap " + focus.label) {
                            _ = vault.release(routineID: focus.routineID, onto: focus.routineID)
                        }
                        .buttonStyle(ProminentPressStyle())
                        .accessibilityHint("Seats " + focus.label + " on its glowing post")
                    }
                    collarStrip
                    actionRow
                    streakFooter
                }
            }
            .padding(ThemeTokens.space * 2)
            .padding(.bottom, ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollDismissesKeyboard(.interactively)
        .onPreferenceChange(SlotFrameKey.self) { frames = $0 }
        .background(DesignTokens.bg.ignoresSafeArea())
        .onAppear { vault.rollDayIfNeeded() }
    }

    private var postColumn: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            Text("Today's posts")
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
            if let focus = focusSlot {
                Button {
                    _ = vault.release(routineID: focus.routineID, onto: focus.routineID)
                } label: {
                    VStack(alignment: .leading, spacing: ThemeTokens.space) {
                        Text(focus.petName + " · " + focus.window)
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                        Text(focus.label)
                            .font(ThemeTokens.font(.display))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Glowing post")
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .padding(.horizontal, ThemeTokens.space)
                            .frame(minHeight: 44)
                            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                    }
                    .padding(ThemeTokens.space * 2)
                    .frame(maxWidth: .infinity, minHeight: 148, alignment: .topLeading)
                    .background(DesignTokens.accent.opacity(0.22), in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                            .stroke(DesignTokens.accent, lineWidth: 3)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                }
                .buttonStyle(PressScaleStyle())
                .background(slotFrame(focus.routineID))
                .accessibilityLabel("Glowing post for " + focus.label + ". Snap " + focus.label)
            }
            ForEach(vault.slots.filter { $0.id != focusSlot?.id }) { slot in
                postRow(slot)
            }
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .paperCard()
    }

    @ViewBuilder
    private func postRow(_ slot: SlotRow) -> some View {
        if slot.post == .seated {
            HStack(spacing: ThemeTokens.space) {
                Text(slot.petName)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Text(slot.label)
                    .font(ThemeTokens.font(.title))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Spacer(minLength: ThemeTokens.space)
                Text("Seated")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
            }
            .padding(.horizontal, ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .background(slotFrame(slot.routineID))
            .accessibilityElement(children: .combine)
        } else if slot.armed {
            Button {
                _ = vault.release(routineID: slot.routineID, onto: slot.routineID)
            } label: {
                HStack(spacing: ThemeTokens.space) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(slot.petName + " · " + slot.window)
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                        Text("Snap " + slot.label)
                            .font(ThemeTokens.font(.title))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                    }
                    Spacer(minLength: ThemeTokens.space)
                    Text("Open")
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                .padding(.horizontal, ThemeTokens.space * 2)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .background(DesignTokens.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous)
                        .stroke(DesignTokens.accent, lineWidth: 2)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleStyle())
            .background(slotFrame(slot.routineID))
        } else {
            Button {
                vault.showOnToday(slot.routineID)
            } label: {
                HStack(spacing: ThemeTokens.space) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(slot.petName + " · " + slot.window)
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                        Text(slot.label)
                            .font(ThemeTokens.font(.title))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(1)
                    }
                    Spacer(minLength: ThemeTokens.space)
                    Text("Show")
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                .padding(.horizontal, ThemeTokens.space * 2)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                .contentShape(Rectangle())
            }
            .buttonStyle(PressScaleStyle())
            .background(slotFrame(slot.routineID))
            .accessibilityLabel("Show " + slot.label + " on Today")
        }
    }

    private func slotFrame(_ id: UUID) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(key: SlotFrameKey.self, value: [id: proxy.frame(in: .global)])
        }
    }

    private var focusSlot: SlotRow? {
        vault.slots.first(where: \.armed)
    }

    private var tray: some View {
        DockBarView(discs: discTokens, phase: vault.phase) {
            DynamicsDockRepresentable(
                discs: discTokens,
                slotFrames: frames,
                reduceMotion: reduceMotion,
                onRelease: { routineID, target in
                    vault.release(routineID: routineID, onto: target)
                }
            )
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .allowsHitTesting(canDrag)
        }
    }

    private var toolRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ThemeTokens.space) {
                tool("pawprint", "Pets") { sheet = .pets }
                tool("checklist", "Chores") { sheet = .routines }
                tool("calendar", "Log") { sheet = .log }
                tool("flag", "Goals") { sheet = .goals }
                tool("gearshape", "Settings") { sheet = .settings }
            }
        }
    }

    private func tool(_ symbol: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: ThemeTokens.space) {
                Image(systemName: symbol)
                    .font(ThemeTokens.font(.body))
                    .accessibilityHidden(true)
                Text(label)
                    .font(ThemeTokens.font(.body))
                    .lineLimit(1)
            }
            .foregroundStyle(DesignTokens.ink)
            .padding(.horizontal, ThemeTokens.space)
            .frame(minWidth: 44, minHeight: 44)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private var actionRow: some View {
        VStack(spacing: ThemeTokens.space) {
            if scanIsPrimary {
                Button("Scan collar") { sheet = .tag }
                    .buttonStyle(ProminentPressStyle())
                    .disabled(isClipped)
            } else {
                Button("Scan collar") { sheet = .tag }
                    .buttonStyle(SecondaryPressStyle())
                    .disabled(isClipped)
            }
            if isClipped {
                Button("Undo seat") { vault.peel() }
                    .buttonStyle(ProminentPressStyle())
                    .disabled(!hasSeat)
            } else {
                Button("Undo seat") { vault.peel() }
                    .buttonStyle(SecondaryPressStyle())
                    .disabled(!hasSeat)
            }
        }
    }

    private var collarStrip: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            Text("Collars")
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
            if cameraDenied {
                Text("Camera is off. Open Settings to change it.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Open Settings") { openSettings() }
                    .buttonStyle(SecondaryPressStyle())
            } else if cameraLive {
                CaptureStrip { code in
                    _ = vault.scan(payload: code)
                    cameraLive = false
                }
                .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                .clipShape(RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous))
            } else {
                Button("Continue") { requestCamera() }
                    .buttonStyle(SecondaryPressStyle())
                Text("Reads a collar code on this device.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.muted)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ThemeTokens.space) {
                    ForEach(vault.ledger.tags) { tag in
                        let name = vault.ledger.pets.first { $0.id == tag.petID }?.name ?? "Pet"
                        Button(name) {
                            _ = vault.scan(payload: tag.code)
                        }
                        .buttonStyle(PressScaleStyle())
                        .font(ThemeTokens.font(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .padding(.horizontal, ThemeTokens.space)
                        .frame(minHeight: 44)
                        .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                        .accessibilityLabel("Scan " + name)
                    }
                }
            }
        }
    }

    private var streakFooter: some View {
        HStack(alignment: .center, spacing: ThemeTokens.space * 2) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Clipped days")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                Text(JauntFormat.tally(vault.streak))
                    .font(ThemeTokens.font(.figure))
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: true)
            }
            Spacer(minLength: ThemeTokens.space)
            Text(JauntFormat.daykeyText(vault.daykey))
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.muted)
                .monospacedDigit()
                .lineLimit(1)
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous))
        .paperShadow()
    }

    private func emptyRail(minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
            Image("chl_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 240)
                .accessibilityHidden(true)
            Text("No chores yet.")
                .font(.custom(DesignTokens.fontFamily, size: displaySize, relativeTo: .largeTitle))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text("Add a pet and a chore.")
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: ThemeTokens.space * 2)
            Button("Add a pet") { sheet = .pets }
                .buttonStyle(ProminentPressStyle())
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .paperCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space) {
            Text(message)
                .font(ThemeTokens.font(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry") { vault.retryLoad() }
                .buttonStyle(ProminentPressStyle())
        }
        .padding(ThemeTokens.space * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .paperCard()
    }

    private var headline: String {
        if let next = vault.slots.first(where: \.armed) {
            return "Snap " + next.label
        }
        switch vault.phase {
        case .blank:
            return "No chores yet"
        case .open:
            return "Scan a collar"
        case .snapping:
            return "Scan the other collar"
        case .clipped:
            return "Day clipped"
        }
    }

    private var isClipped: Bool {
        if case .clipped = vault.phase { return true }
        return false
    }

    private var scanIsPrimary: Bool {
        if case .open = vault.phase { return true }
        return false
    }

    private var hasSeat: Bool {
        vault.slots.contains { $0.post == .seated }
    }

    private var canDrag: Bool {
        vault.phase != .clipped && vault.phase != .blank
    }

    private var discTokens: [DiscToken] {
        let seated = Set(vault.slots.filter { $0.post == .seated }.map(\.routineID))
        let armedPet: UUID? = {
            if case .snapping(let petID) = vault.phase { return petID }
            return nil
        }()
        return vault.ledger.routines.filter(\.isActive).filter { !seated.contains($0.id) }.map { routine in
            let petMatch = armedPet == nil || routine.petID == armedPet
            return DiscToken(id: routine.id, label: routine.label, enabled: canDrag && petMatch)
        }
    }

    private func requestCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraLive = true
        case .denied, .restricted:
            cameraDenied = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { allowed in
                Task { @MainActor in
                    cameraDenied = !allowed
                    cameraLive = allowed
                }
            }
        @unknown default:
            cameraDenied = true
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

enum CoverSheet: String, Identifiable {
    case pets, routines, settings, log, goals
    case slot, dock, disc, peel, tag, skew, drift, clip
    var id: String { rawValue }
}
