import Foundation

/// Jaunt-rail ADT. The day folds Blank, Open, Snapping, or Clipped over Slots.
enum RailFoldState: Equatable, Sendable {
    case blank
    case open
    case snapping(petID: UUID)
    case clipped
}

/// Slot posture after the fold. Bare until a SeatMark lands.
enum SlotPost: Equatable, Sendable {
    case bare
    case seated
}

struct SlotRow: Identifiable, Equatable, Sendable {
    var id: UUID { routineID }
    var routineID: UUID
    var petID: UUID
    var label: String
    var petName: String
    var window: String
    var post: SlotPost
    var armed: Bool
}

enum RailFold {
    static func daykey(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }

    static func previousDay(from date: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: -1, to: start) ?? start
    }

    static func phase(ledger: JauntLedger, daykey: Int) -> RailFoldState {
        let active = ledger.routines.filter(\.isActive)
        if ledger.pets.isEmpty || active.isEmpty {
            return .blank
        }
        if hasClip(ledger: ledger, daykey: daykey), allSeated(ledger: ledger, daykey: daykey) {
            return .clipped
        }
        if let petID = latestTag(ledger: ledger, daykey: daykey)?.petID {
            return .snapping(petID: petID)
        }
        return .open
    }

    static func slots(ledger: JauntLedger, daykey: Int) -> [SlotRow] {
        let phase = phase(ledger: ledger, daykey: daykey)
        let armedPet: UUID? = {
            if case .snapping(let petID) = phase { return petID }
            return nil
        }()
        let seated = Set(ledger.marks.filter { $0.kind == .seat && $0.daykey == daykey }.compactMap(\.routineID))
        return ledger.routines.filter(\.isActive).map { routine in
            let petName = ledger.pets.first { $0.id == routine.petID }?.name ?? ""
            return SlotRow(
                routineID: routine.id,
                petID: routine.petID,
                label: routine.label,
                petName: petName,
                window: routine.window,
                post: seated.contains(routine.id) ? .seated : .bare,
                armed: armedPet == routine.petID && !seated.contains(routine.id)
            )
        }
    }

    static func scan(ledger: inout JauntLedger, payload: String, daykey: Int, now: Date) -> Result<UUID, RailRefusal> {
        switch phase(ledger: ledger, daykey: daykey) {
        case .clipped:
            return .failure(.clippedScan)
        case .blank:
            return .failure(.blankHousehold)
        case .open, .snapping:
            break
        }
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let tag = ledger.tags.first(where: { $0.code.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            return .failure(.unknownTag)
        }
        ledger.marks.append(JauntMark(id: UUID(), kind: .tag, daykey: daykey, petID: tag.petID, routineID: nil, created: now))
        return .success(tag.petID)
    }

    static func release(
        ledger: inout JauntLedger,
        routineID: UUID,
        onto targetRoutineID: UUID?,
        daykey: Int,
        now: Date
    ) -> ReleaseOutcome {
        switch phase(ledger: ledger, daykey: daykey) {
        case .clipped:
            return .refused(.clippedDrag)
        case .blank:
            return .refused(.blankHousehold)
        case .open:
            ledger.marks.append(JauntMark(id: UUID(), kind: .drift, daykey: daykey, petID: nil, routineID: routineID, created: now))
            return .drift
        case .snapping(let petID):
            guard let targetRoutineID else { return .missed }
            guard let routine = ledger.routines.first(where: { $0.id == routineID && $0.isActive }) else {
                return .missed
            }
            let seated = ledger.marks.contains { $0.kind == .seat && $0.daykey == daykey && $0.routineID == targetRoutineID }
            if seated { return .refused(.alreadySeated) }
            let matches = routine.id == targetRoutineID && routine.petID == petID
            if !matches {
                ledger.marks.append(JauntMark(id: UUID(), kind: .skew, daykey: daykey, petID: petID, routineID: routineID, created: now))
                return .skew
            }
            ledger.marks.append(JauntMark(id: UUID(), kind: .seat, daykey: daykey, petID: petID, routineID: routineID, created: now))
            if allSeated(ledger: ledger, daykey: daykey) {
                ledger.marks.append(JauntMark(id: UUID(), kind: .clip, daykey: daykey, petID: nil, routineID: nil, created: now))
                return .clipped
            }
            return .seated
        }
    }

    /// Peel drops the last SeatMark. Clipped reopens to Snapping when any slot is bare.
    static func peel(ledger: inout JauntLedger, daykey: Int) -> Bool {
        guard let index = ledger.marks.lastIndex(where: { $0.kind == .seat && $0.daykey == daykey }) else {
            return false
        }
        ledger.marks.remove(at: index)
        if !allSeated(ledger: ledger, daykey: daykey) {
            ledger.marks.removeAll { $0.kind == .clip && $0.daykey == daykey }
        }
        return true
    }

    static func streak(ledger: JauntLedger, from date: Date, calendar: Calendar = .current) -> Int {
        var cursor = calendar.startOfDay(for: date)
        var count = 0
        for _ in 0..<400 {
            let key = daykey(for: cursor, calendar: calendar)
            let active = ledger.routines.filter(\.isActive)
            guard !active.isEmpty, hasClip(ledger: ledger, daykey: key), allSeated(ledger: ledger, daykey: key) else {
                break
            }
            count += 1
            cursor = previousDay(from: cursor, calendar: calendar)
        }
        return count
    }

    static func weekCSV(ledger: JauntLedger, ending date: Date, calendar: Calendar = .current) -> String {
        var lines = ["daykey,pet,routine,state"]
        let end = calendar.startOfDay(for: date)
        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: end) else { continue }
            let key = daykey(for: day, calendar: calendar)
            for routine in ledger.routines where routine.isActive {
                let pet = ledger.pets.first { $0.id == routine.petID }?.name ?? ""
                let seated = ledger.marks.contains { $0.kind == .seat && $0.daykey == key && $0.routineID == routine.id }
                lines.append("\(key),\(pet),\(routine.label),\(seated ? "seated" : "bare")")
            }
        }
        return lines.joined(separator: "\n")
    }

    static func allSeated(ledger: JauntLedger, daykey: Int) -> Bool {
        let active = ledger.routines.filter(\.isActive)
        guard !active.isEmpty else { return false }
        return active.allSatisfy { routine in
            ledger.marks.contains { $0.kind == .seat && $0.daykey == daykey && $0.routineID == routine.id }
        }
    }

    private static func hasClip(ledger: JauntLedger, daykey: Int) -> Bool {
        ledger.marks.contains { $0.kind == .clip && $0.daykey == daykey }
    }

    private static func latestTag(ledger: JauntLedger, daykey: Int) -> JauntMark? {
        ledger.marks.last { $0.kind == .tag && $0.daykey == daykey }
    }
}
