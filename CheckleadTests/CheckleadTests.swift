import XCTest
@testable import Checklead

final class CheckleadTests: XCTestCase {
    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.argument, "-ReviewScreen")
        let screen = ReviewLaunch.screen
        if ProcessInfo.processInfo.arguments.contains("-ReviewScreen") {
            XCTAssertNotNil(screen)
        } else {
            XCTAssertNil(screen)
        }
    }

    func testEmptyHouseholdIsBlank() {
        let phase = RailFold.phase(ledger: .empty, daykey: 20261021)
        XCTAssertEqual(phase, .blank)
        var ledger = JauntLedger.empty
        let scan = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: 20261021, now: Date())
        XCTAssertEqual(scan, .failure(.blankHousehold))
    }

    func testScanThenSeatThenClipAndRefuseScan() {
        var ledger = sample()
        let day = 20261021
        XCTAssertEqual(RailFold.phase(ledger: ledger, daykey: day), .open)
        let scanned = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: day, now: Date())
        guard case .success = scanned else {
            return XCTFail("scan")
        }
        XCTAssertEqual(RailFold.phase(ledger: ledger, daykey: day), .snapping(petID: mira))
        let seated = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: day, now: Date())
        XCTAssertEqual(seated, .seated)
        XCTAssertEqual(RailFold.slots(ledger: ledger, daykey: day).first { $0.routineID == feed }?.post, .seated)
        let clipped = RailFold.release(ledger: &ledger, routineID: walk, onto: walk, daykey: day, now: Date())
        XCTAssertEqual(clipped, .clipped)
        XCTAssertEqual(RailFold.phase(ledger: ledger, daykey: day), .clipped)
        let refused = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: day, now: Date())
        XCTAssertEqual(refused, .failure(.clippedScan))
        let drag = RailFold.release(ledger: &ledger, routineID: walk, onto: walk, daykey: day, now: Date())
        XCTAssertEqual(drag, .refused(.clippedDrag))
    }

    func testSkewDriftAndPeel() {
        var ledger = sample()
        let day = 20261021
        let drift = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: day, now: Date())
        XCTAssertEqual(drift, .drift)
        _ = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: day, now: Date())
        let skew = RailFold.release(ledger: &ledger, routineID: feed, onto: walk, daykey: day, now: Date())
        XCTAssertEqual(skew, .skew)
        _ = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: day, now: Date())
        XCTAssertTrue(PeelCommand.apply(ledger: &ledger, daykey: day))
        XCTAssertEqual(RailFold.phase(ledger: ledger, daykey: day), .snapping(petID: mira))
        XCTAssertEqual(RailFold.slots(ledger: ledger, daykey: day).first { $0.routineID == feed }?.post, .bare)
    }

    func testUnknownTagAndStreakWalksBackward() {
        var ledger = sample()
        let day = 20261021
        XCTAssertEqual(RailFold.scan(ledger: &ledger, payload: "NOPE", daykey: day, now: Date()), .failure(.unknownTag))
        _ = RailFold.scan(ledger: &ledger, payload: "chl-mira", daykey: day, now: Date())
        _ = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: day, now: Date())
        _ = RailFold.release(ledger: &ledger, routineID: walk, onto: walk, daykey: day, now: Date())
        let calendar = Calendar(identifier: .gregorian)
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 10
        parts.day = 21
        let date = calendar.date(from: parts) ?? Date()
        XCTAssertEqual(RailFold.streak(ledger: ledger, from: date, calendar: calendar), 1)
        XCTAssertGreaterThan(RailFold.weekCSV(ledger: ledger, ending: date, calendar: calendar).count, 10)
    }

    func testDayCompleteIffEveryActiveRoutineIsSeatedAndStreakWalksBackward() {
        var ledger = sample()
        ledger.routines.append(Routine(id: UUID(), petID: mira, label: "Bath", window: "Night", isActive: false))
        let today = 20261021
        let yesterday = 20261020
        _ = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: yesterday, now: Date())
        _ = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: yesterday, now: Date())
        XCTAssertFalse(RailFold.allSeated(ledger: ledger, daykey: yesterday))
        XCTAssertNotEqual(RailFold.phase(ledger: ledger, daykey: yesterday), .clipped)
        _ = RailFold.release(ledger: &ledger, routineID: walk, onto: walk, daykey: yesterday, now: Date())
        XCTAssertTrue(RailFold.allSeated(ledger: ledger, daykey: yesterday))
        XCTAssertEqual(RailFold.phase(ledger: ledger, daykey: yesterday), .clipped)
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 10
        parts.day = 21
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: parts) ?? Date()
        XCTAssertEqual(RailFold.streak(ledger: ledger, from: date, calendar: calendar), 0)
        _ = RailFold.scan(ledger: &ledger, payload: "CHL-MIRA", daykey: today, now: Date())
        _ = RailFold.release(ledger: &ledger, routineID: feed, onto: feed, daykey: today, now: Date())
        _ = RailFold.release(ledger: &ledger, routineID: walk, onto: walk, daykey: today, now: Date())
        XCTAssertEqual(RailFold.streak(ledger: ledger, from: date, calendar: calendar), 2)
    }

    func testLedgerRoundTrip() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        let url = directory.appendingPathComponent("jaunt-ledger.json")
        let backup = directory.appendingPathComponent("jaunt-ledger.json.backup")
        var ledger = sample()
        ledger.onboardingComplete = true
        let data = try JSONEncoder().encode(ledger)
        try data.write(to: url, options: .atomic)
        defaults.set(data, forKey: JauntVault.defaultsKey)
        let loaded = JauntVault.load(from: url, backup: backup, defaults: defaults, decoder: JSONDecoder())
        XCTAssertNil(loaded.error)
        XCTAssertEqual(loaded.ledger.pets.map(\.name), ["Mira"])
        XCTAssertEqual(loaded.ledger.schemaVersion, 1)
        let junk = directory.appendingPathComponent("jaunt-ledger.json")
        try Data("{".utf8).write(to: junk, options: .atomic)
        try data.write(to: backup, options: .atomic)
        defaults.removeObject(forKey: JauntVault.defaultsKey)
        let repaired = JauntVault.load(from: junk, backup: backup, defaults: defaults, decoder: JSONDecoder())
        XCTAssertEqual(repaired.ledger.routines.count, 2)
        XCTAssertNotNil(repaired.error)
    }

    private let mira = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let feed = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
    private let walk = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!

    private func sample() -> JauntLedger {
        var ledger = JauntLedger.empty
        ledger.pets = [Pet(id: mira, name: "Mira", note: "")]
        ledger.tags = [CollarTag(id: UUID(), petID: mira, code: "CHL-MIRA")]
        ledger.routines = [
            Routine(id: feed, petID: mira, label: "Feed", window: "Morning", isActive: true),
            Routine(id: walk, petID: mira, label: "Walk", window: "Afternoon", isActive: true)
        ]
        return ledger
    }
}
