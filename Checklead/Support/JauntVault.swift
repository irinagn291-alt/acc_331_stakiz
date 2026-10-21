import Foundation

/// Storage seam. UI talks to this type. Disk and UserDefaults are a projection.
@MainActor
final class JauntVault: ObservableObject {
    @Published private(set) var ledger: JauntLedger
    @Published private(set) var loadError: String?
    @Published private(set) var statusLine: String
    @Published var spotlightID: UUID?
    @Published var day: Date

    private let defaults: UserDefaults
    private let directory: URL
    private let fileURL: URL
    private let backupURL: URL
    private var saveTask: Task<Void, Never>?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    nonisolated static let defaultsKey = "chl.ledger.v1"
    nonisolated static let demoKey = "chl.demo.v1"

    init(defaults: UserDefaults = .standard, directory: URL? = nil, now: Date = Date()) {
        self.defaults = defaults
        let base = directory ?? Self.supportDirectory()
        self.directory = base
        self.fileURL = base.appendingPathComponent("jaunt-ledger.json")
        self.backupURL = base.appendingPathComponent("jaunt-ledger.json.backup")
        self.day = Calendar.current.startOfDay(for: now)
        encoder.outputFormatting = [.sortedKeys]
        let loaded = Self.load(from: fileURL, backup: backupURL, defaults: defaults, decoder: decoder)
        ledger = loaded.ledger
        loadError = loaded.error
        statusLine = "Rail ready."
        if ledger.pets.isEmpty && ledger.marks.isEmpty && !ledger.onboardingComplete {
            seedIfSimulator()
        }
        refreshStatus()
    }

    var daykey: Int { RailFold.daykey(for: day) }

    var phase: RailFoldState { RailFold.phase(ledger: ledger, daykey: daykey) }

    var slots: [SlotRow] { RailFold.slots(ledger: ledger, daykey: daykey) }

    var streak: Int { RailFold.streak(ledger: ledger, from: day) }

    func rollDayIfNeeded(now: Date = Date()) {
        let start = Calendar.current.startOfDay(for: now)
        if start != day {
            day = start
            refreshStatus()
        }
    }

    func completeOnboarding() {
        ledger.onboardingComplete = true
        scheduleSave(immediate: true)
    }

    func scan(payload: String) -> Result<UUID, RailRefusal> {
        let result = RailFold.scan(ledger: &ledger, payload: payload, daykey: daykey, now: Date())
        switch result {
        case .success:
            statusLine = "Collar read. Empty posts are armed."
            scheduleSave()
        case .failure(.clippedScan):
            statusLine = "Day clipped. Undo the last seat, then scan."
        case .failure(.unknownTag):
            statusLine = "Scan failed. Try again."
        case .failure(.blankHousehold):
            statusLine = "Add a pet before scanning."
        case .failure:
            statusLine = "Scan failed. Try again."
        }
        return result
    }

    func release(routineID: UUID, onto targetRoutineID: UUID?) -> ReleaseOutcome {
        let outcome = RailFold.release(
            ledger: &ledger,
            routineID: routineID,
            onto: targetRoutineID,
            daykey: daykey,
            now: Date()
        )
        switch outcome {
        case .seated:
            statusLine = "Seated."
        case .clipped:
            statusLine = "Day clipped."
        case .skew:
            statusLine = "Wrong post. It bounced back."
        case .drift:
            statusLine = "Scan a collar, then drag the chore."
        case .missed:
            statusLine = "Missed the post. Try again."
        case .refused(.clippedDrag):
            statusLine = "Day clipped. Undo the last seat, then drag."
        case .refused(.alreadySeated):
            statusLine = "That post already holds a chore."
        case .refused:
            statusLine = "Snap failed. Try again."
        }
        if outcome == .seated || outcome == .clipped || outcome == .skew || outcome == .drift {
            scheduleSave()
        }
        return outcome
    }

    func showOnToday(_ routineID: UUID) {
        spotlightID = routineID
        if let row = slots.first(where: { $0.routineID == routineID }) {
            statusLine = row.label + " is marked on today. Drag it onto its post."
        }
    }

    func peel() {
        if PeelCommand.apply(ledger: &ledger, daykey: daykey) {
            statusLine = "Last seat lifted. Drag is open."
            scheduleSave()
        } else {
            statusLine = "No seat to undo."
        }
    }

    func addPet(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusLine = "Name missing. Type a pet name."
            return
        }
        let pet = Pet(id: UUID(), name: trimmed, note: "")
        let code = "CHL-" + trimmed.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(8)
        ledger.pets.append(pet)
        ledger.tags.append(CollarTag(id: UUID(), petID: pet.id, code: String(code)))
        statusLine = "Pet added."
        scheduleSave(immediate: true)
    }

    func addRoutine(petID: UUID, label: String, window: String) {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusLine = "Name missing. Type a chore name."
            return
        }
        guard ledger.pets.contains(where: { $0.id == petID }) else {
            statusLine = "Pick a pet for this chore."
            return
        }
        ledger.routines.append(Routine(id: UUID(), petID: petID, label: trimmed, window: window.isEmpty ? "Today" : window, isActive: true))
        statusLine = "Chore added."
        scheduleSave(immediate: true)
    }

    func setRoutineActive(_ id: UUID, active: Bool) {
        guard let index = ledger.routines.firstIndex(where: { $0.id == id }) else { return }
        ledger.routines[index].isActive = active
        scheduleSave()
    }

    func updateRoutineLabel(_ id: UUID, label: String) {
        guard let index = ledger.routines.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        ledger.routines[index].label = trimmed
        scheduleSave()
    }

    func resetAllData() {
        saveTask?.cancel()
        ledger = .empty
        loadError = nil
        statusLine = "Household cleared."
        try? FileManager.default.removeItem(at: fileURL)
        defaults.removeObject(forKey: Self.defaultsKey)
        scheduleSave(immediate: true)
    }

    func retryLoad() {
        let loaded = Self.load(from: fileURL, backup: backupURL, defaults: defaults, decoder: decoder)
        ledger = loaded.ledger
        loadError = loaded.error
        refreshStatus()
    }

    func reseedDemo() {
        #if targetEnvironment(simulator)
        defaults.removeObject(forKey: Self.demoKey)
        ledger = Self.demoLedger(now: Date())
        defaults.set(true, forKey: Self.demoKey)
        statusLine = "Demo household restored. Snap the next chore."
        scheduleSave(immediate: true)
        #endif
    }

    func csv() -> String {
        RailFold.weekCSV(ledger: ledger, ending: day)
    }

    func flush() {
        saveTask?.cancel()
        persistNow()
    }

    private func refreshStatus() {
        switch phase {
        case .blank:
            statusLine = "Household empty. Add a pet."
        case .open:
            statusLine = "Scan a collar."
        case .snapping:
            if let next = slots.first(where: \.armed) {
                statusLine = next.label + " is open. Drag it onto the glowing post."
            } else {
                statusLine = "Scan the other collar to arm its chores."
            }
        case .clipped:
            statusLine = "Day clipped."
        }
    }

    private func scheduleSave(immediate: Bool = false) {
        saveTask?.cancel()
        if immediate {
            persistNow()
            return
        }
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 280_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.persistNow() }
        }
    }

    private func persistNow() {
        let snapshot = ledger
        let url = fileURL
        let backup = backupURL
        let folder = directory
        let data: Data
        do {
            data = try encoder.encode(snapshot)
        } catch {
            loadError = "Save failed. Try again."
            return
        }
        defaults.set(data, forKey: Self.defaultsKey)
        Task.detached {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: backup)
                    try FileManager.default.copyItem(at: url, to: backup)
                }
                try data.write(to: url, options: .atomic)
                var values = URLResourceValues()
                values.isExcludedFromBackup = false
                var mutable = url
                try? mutable.setResourceValues(values)
            } catch {
                await MainActor.run { [weak self] in
                    self?.loadError = "Save failed. Try again."
                }
            }
        }
    }

    private func seedIfSimulator() {
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: Self.demoKey) { return }
        ledger = Self.demoLedger(now: day)
        defaults.set(true, forKey: Self.demoKey)
        scheduleSave(immediate: true)
        #endif
    }

    nonisolated static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("Stakiz", isDirectory: true)
    }

    nonisolated static func demoLedger(now: Date) -> JauntLedger {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let earlier = calendar.date(byAdding: .day, value: -2, to: today) ?? yesterday
        let mira = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000001") ?? UUID()
        let pip = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000002") ?? UUID()
        let feed = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000011") ?? UUID()
        let walk = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000012") ?? UUID()
        let water = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000013") ?? UUID()
        let brush = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000014") ?? UUID()
        let key = RailFold.daykey(for: today, calendar: calendar)
        let ykey = RailFold.daykey(for: yesterday, calendar: calendar)
        let ekey = RailFold.daykey(for: earlier, calendar: calendar)
        var ledger = JauntLedger.empty
        ledger.onboardingComplete = true
        ledger.pets = [
            Pet(id: mira, name: "Mira", note: "Lead collar"),
            Pet(id: pip, name: "Pip", note: "Second collar")
        ]
        ledger.tags = [
            CollarTag(id: UUID(), petID: mira, code: "CHL-MIRA"),
            CollarTag(id: UUID(), petID: pip, code: "CHL-PIP")
        ]
        ledger.routines = [
            Routine(id: feed, petID: mira, label: "Feed", window: "Morning", isActive: true),
            Routine(id: walk, petID: mira, label: "Walk", window: "Afternoon", isActive: true),
            Routine(id: brush, petID: mira, label: "Brush", window: "Evening", isActive: true),
            Routine(id: water, petID: pip, label: "Water", window: "Night", isActive: true)
        ]
        var marks: [JauntMark] = [
            JauntMark(id: UUID(), kind: .drift, daykey: ekey, petID: mira, routineID: walk, created: earlier)
        ]
        marks.append(JauntMark(id: UUID(), kind: .tag, daykey: ykey, petID: mira, routineID: nil, created: yesterday))
        for routine in [feed, walk, brush, water] {
            let pet = routine == water ? pip : mira
            marks.append(JauntMark(id: UUID(), kind: .seat, daykey: ykey, petID: pet, routineID: routine, created: yesterday))
        }
        marks.append(JauntMark(id: UUID(), kind: .clip, daykey: ykey, petID: nil, routineID: nil, created: yesterday))
        marks.append(JauntMark(id: UUID(), kind: .tag, daykey: key, petID: mira, routineID: nil, created: today))
        marks.append(JauntMark(id: UUID(), kind: .seat, daykey: key, petID: mira, routineID: feed, created: today))
        marks.append(JauntMark(id: UUID(), kind: .skew, daykey: key, petID: mira, routineID: walk, created: today))
        ledger.marks = marks
        return ledger
    }

    nonisolated static func load(
        from url: URL,
        backup: URL,
        defaults: UserDefaults,
        decoder: JSONDecoder
    ) -> (ledger: JauntLedger, error: String?) {
        if let data = try? Data(contentsOf: url), let ledger = decode(data, decoder: decoder) {
            return (ledger, nil)
        }
        if let data = try? Data(contentsOf: backup), let ledger = decode(data, decoder: decoder) {
            return (ledger, "Last save was repaired from the backup.")
        }
        if let data = defaults.data(forKey: defaultsKey), let ledger = decode(data, decoder: decoder) {
            return (ledger, nil)
        }
        if FileManager.default.fileExists(atPath: url.path) {
            return (.empty, "Household file was unreadable. Start fresh or retry.")
        }
        return (.empty, nil)
    }

    nonisolated private static func decode(_ data: Data, decoder: JSONDecoder) -> JauntLedger? {
        guard let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let version = raw["schemaVersion"] as? Int ?? 0
        guard version == 1 else { return nil }
        return try? decoder.decode(JauntLedger.self, from: data)
    }
}
