import Foundation

/// Household animal. A Pet owns Tags and the Routines that become Slots.
struct Pet: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var name: String
    var note: String
}

/// Collar payload. Scan matches `code` and writes TagMark for `petID`.
struct CollarTag: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var petID: UUID
    var code: String
}

/// Disc template. Active routines become Slots on the daykey rail.
struct Routine: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var petID: UUID
    var label: String
    var window: String
    var isActive: Bool
}

/// Chart root. Islands, books, sessions, runs, and rhumbs are the persisted fold.
struct JauntLedger: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var pets: [Pet]
    var tags: [CollarTag]
    var routines: [Routine]
    var marks: [JauntMark]
    var onboardingComplete: Bool
    var loadNote: String?

    static let empty = JauntLedger(
        schemaVersion: 1,
        pets: [],
        tags: [],
        routines: [],
        marks: [],
        onboardingComplete: false,
        loadNote: nil
    )
}

enum JauntFormat {
    static func tally(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    static func daykeyText(_ daykey: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: daykey)) ?? ""
    }
}
