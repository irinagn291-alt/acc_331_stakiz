import SwiftUI

@main
struct CheckleadWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot()
        }
    }
}

/// Apple Watch cover. Read `ReviewLaunch.screen` and open the same
/// today / log / goals destinations as the iPhone app.
private func watchPage(title: String, detail: String, figure: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.headline)
        Text(figure)
            .font(.title2)
            .monospacedDigit()
        Text(detail)
            .font(.caption)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

struct WatchRoot: View {
    var body: some View {
        switch ReviewLaunch.screen {
        case "log":
            watchPage(title: "Week", detail: "Seated chores and misses", figure: "7")
        case "goals":
            watchPage(title: "Streak", detail: "Consecutive clipped days", figure: "0")
        case "pets", "pet":
            watchPage(title: "Pets", detail: "Mira and Pip", figure: "2")
        case "routines", "routine":
            watchPage(title: "Chores", detail: "Feed, Walk, Brush, Water", figure: "4")
        case "settings":
            watchPage(title: "Settings", detail: "Camera, reset, support", figure: "")
        case "slot":
            watchPage(title: "Posts", detail: "Walk is ready", figure: "4")
        case "dock", "disc":
            watchPage(title: "Tray", detail: "Drag Walk next", figure: "3")
        case "peel":
            watchPage(title: "Undo", detail: "Lift the last seat", figure: "1")
        case "tag":
            watchPage(title: "Collar", detail: "Mira is read", figure: "2")
        default:
            watchPage(title: "Snap Walk", detail: "Drag the open chore onto its post.", figure: "1")
        }
    }
}
