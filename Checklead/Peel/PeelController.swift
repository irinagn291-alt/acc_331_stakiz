import Foundation

/// Peel command. Removes the latest SeatMark and lets the fold reopen Snapping.
enum PeelCommand {
    @discardableResult
    static func apply(ledger: inout JauntLedger, daykey: Int) -> Bool {
        RailFold.peel(ledger: &ledger, daykey: daykey)
    }
}
