import Foundation

/// One persisted event on the jaunt rail: tag, seat, skew, drift, or clip.
struct JauntMark: Codable, Identifiable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case tag
        case seat
        case skew
        case drift
        case clip
    }

    var id: UUID
    var kind: Kind
    var daykey: Int
    var petID: UUID?
    var routineID: UUID?
    var created: Date
}

/// Why a scan or drag was refused. Clipped refusals are unit-tested.
enum RailRefusal: Error, Equatable, Sendable {
    case clippedScan
    case clippedDrag
    case unknownTag
    case blankHousehold
    case notSnapping
    case alreadySeated
}

enum ReleaseOutcome: Equatable, Sendable {
    case seated
    case skew
    case drift
    case clipped
    case refused(RailRefusal)
    case missed
}
