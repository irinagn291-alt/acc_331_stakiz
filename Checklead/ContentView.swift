import SwiftUI

struct ContentView: View {
    @StateObject private var vault = JauntVault()
    @Environment(\.scenePhase) private var scenePhase
    @State private var sheet: CoverSheet?
    @State private var showOnboarding = false
    @State private var didRouteReview = false

    var body: some View {
        TodayRailScreen(vault: vault, sheet: $sheet)
            .fullScreenCover(item: $sheet) { cover in
                sheetView(cover)
                    .modifier(SheetEntry())
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    vault.completeOnboarding()
                    showOnboarding = false
                    routeReviewIfNeeded()
                }
                .modifier(SheetEntry())
            }
            .onAppear {
                if vault.ledger.onboardingComplete {
                    routeReviewIfNeeded()
                } else {
                    showOnboarding = true
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .inactive || phase == .background {
                    vault.flush()
                }
                vault.rollDayIfNeeded()
            }
    }

    @ViewBuilder
    private func sheetView(_ cover: CoverSheet) -> some View {
        switch cover {
        case .pets:
            PetScreen(vault: vault)
        case .routines:
            RoutineScreen(vault: vault)
        case .settings:
            SettingsSheet(vault: vault, showOnboarding: $showOnboarding)
        case .log:
            HistoryLogSheet(vault: vault)
        case .goals:
            StreakGoalsSheet(vault: vault)
        case .slot:
            SlotScreen(vault: vault)
        case .dock:
            DockScreen(vault: vault)
        case .disc:
            DiscScreen(vault: vault)
        case .peel:
            PeelScreen(vault: vault)
        case .tag:
            TagScannerView(vault: vault)
        case .skew:
            SkewMarkScreen(vault: vault)
        case .drift:
            DriftMarkScreen(vault: vault)
        case .clip:
            ClipMarkScreen(vault: vault)
        }
    }

    private func routeReviewIfNeeded() {
        guard !didRouteReview, let screen = ReviewLaunch.screen else { return }
        didRouteReview = true
        switch screen {
        case "today", "todayrailscreen":
            sheet = nil
        case "log":
            sheet = .log
        case "goals":
            sheet = .goals
        case "pets", "pet":
            sheet = .pets
        case "routines", "routine":
            sheet = .routines
        case "settings":
            sheet = .settings
        case "slot":
            sheet = .slot
        case "dock":
            sheet = .dock
        case "disc":
            sheet = .disc
        case "peel":
            sheet = .peel
        case "tag":
            sheet = .tag
        case "skewmark", "skew":
            sheet = .skew
        case "driftmark", "drift":
            sheet = .drift
        case "clipmark", "clip":
            sheet = .clip
        default:
            sheet = nil
        }
    }
}

struct OnboardingView: View {
    var finish: () -> Void
    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [(String, String, String)] = [
        ("chl_Onboarding1", "Collar chores", "Each pet keeps today's chores on one paper column."),
        ("chl_Onboarding2", "Scan, then snap", "Read a collar, then drag the chore onto its post."),
        ("chl_Onboarding3", "Clip the day", "When every chore is seated, the day clips shut.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .frame(minWidth: 44, minHeight: 44)
            }
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                        Image(pages[index].0)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 360)
                            .accessibilityHidden(true)
                        Text(pages[index].1)
                            .font(ThemeTokens.font(.display))
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(pages[index].2)
                            .font(ThemeTokens.font(.body))
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: ThemeTokens.space)
                    }
                    .padding(ThemeTokens.space * 2)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            Button(page < 2 ? "Next" : "Continue") {
                if page < 2 {
                    page += 1
                } else {
                    finish()
                }
            }
            .buttonStyle(ProminentPressStyle())
            .padding(.horizontal, ThemeTokens.space * 2)
        }
        .padding(ThemeTokens.space * 2)
        .background(DesignTokens.bg.ignoresSafeArea())
        .animation(reduceMotion ? .none : .easeOut(duration: ThemeTokens.sheetDuration), value: page)
    }
}

#Preview {
    ContentView()
}
